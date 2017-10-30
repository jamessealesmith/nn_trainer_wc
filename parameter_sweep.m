%% Parameter Sweep
%
% Prepare Workspace
clear all; close all; clc;
logS = prepare_workspace();

%% User Input

% ***** Select data: *****
% dataS = 'XOR_uni.dat';
dataS = 'parity7.dat';
% dataS = 'spiral.dat';
% dataS = 'peaks2000.dat';
% dataS = 'flowers.dat';
% dataS = 'flowers_class.dat';
% dataS = 'abalone.dat';
% dataS = 'ELEC6240.dat';
% dataS = 'concrete.dat';
% dataS = 'housing.dat';

% ***** Select algorithm: *****
% 1 = nbn, 2 = nbn_wc, 3 = nbn_rr
% 51 = ebp, 52 = ebp_wc
% 0 = sandbox!
alg = 2;

% ***** Set algorithm parameters: *****
% Parameter value vectors match "param_names" for corresponding algorithm. 
% Keep unused parameter vectors set as "-1"
if(alg == 1) % nbn
    param_names = ["h"];  
elseif(alg == 2) % nbn_wc
    param_names = ["h","wc_setting","beta","omega","rho"];  
elseif(alg == 3) % nbn_rr
    param_names = ["h","wc_setting","beta"];   
elseif(alg == 51) % ebp
    param_names = ["h","c","momentum"];
elseif(alg == 52) % ebp_wc
    param_names = ["h","c","wc_setting","beta","omega","rho"];  
elseif(alg == 0) % sandbox
   param_names = ["h","c","momentum"];
end
valuesA = [2];
valuesB = [1];
valuesC = [10^-3 10^-4 10^-5];
valuesD = [1];
valuesE = [1.1] ;
valuesF = [-1];
    
% ***** Set Network Parameters: *****
no = 1;          % Number outputs
type = 1;        % 1 = FCC, 2 = MLP

% MLP Only
nL = 1;          % Number of layers

% Activation, 0 = linear, 1 = unipolar, 2 = bipolar
actH = 2;        % activation of hidden layer neurons
actF = 0;        % activation of output neuron

% Other
gainMag = 1.0;

% ***** Set Training Parameters: *****
desErr = 0.1;                   % Desired Error
maxIter = 100;                   % Maximum Iterations
ntrials = 100;                   % Number of training trials
train_per = 1.0;                   % Percent training data, 1 = train all
randF = -1;                      % > 0 randomly permutates dataset
normF = 1;                       % > 0 = normalize data
earlyF = 1;                      % > 0 = stop if reach desired error
nhF = -1;                        % > 0, Nguyen and Widrow weight initialization
criterionF = 1;                  % < 0 = error, else = success rate
batchF = 2;                      % <=0 = no trial results / no graph
                                 % 1 = print trial results / no graph
                                 % 2 = print trial results/graph rmse

%% End User Input

% Load Data
data = load(dataS);

% Randomize if asked
np = size(data,1);
if(randF > 0)
    ind = randperm(np);
    data = data(ind,:);
    randF = -1;
end

% Process Parameters
train_set = {alg,desErr,maxIter,ntrials,train_per,normF,earlyF,batchF,nhF};

% Start Diary
diary(logS);

% Title Run
c = clock;
fprintf('\n\n\n\n\n\n\n\n\n\n')
fprintf('%s\n',datestr(datenum(c(1),c(2),c(3),c(4),c(5),c(6))))
fprintf('Algorithm Development\n');
fprintf('Data - %s\n',dataS);
fprintf('Alg - %s\n\n',algDirectory(alg));
fprintf('Test Parameters:\nDE = %f\nMax Iter = %d\nTrials = %d\n\n'...
    ,desErr,maxIter,ntrials);

%% Begin Sweep
fprintf('******************** PARAMETER SWEEP ********************\n\n')
if(criterionF < 0)
    crit = 1E3;
else
    crit = 0;
end

best_train = -1*ones(1,2);
best_test = -1*ones(1,2);
best_time = -1*ones(1,4);
bestD = -1 * ones(1,6);
test_iter = 1;
for D1 = valuesA
    for D2 = valuesB
        for D3 = valuesC
            for D4 = valuesD
                for D5 = valuesE
                    for D6 = valuesF
                        
                        % Network Architecture w/o inputs
                        if(type == 1)
                            network = [ones(1,D1) no];
                        else
                            network = [D1*ones(1,nL) no];
                        end
                        nn_h = sum(network)-no; % Number of hidden neurons
                        alg_settings = [D2 D3 D4 D5 D6]; % Algorithm settings
                        net_set = {type,actH,actF,gainMag}; % Network settings
                        
                        % Resume Diary
                        diary(logS);
                        
                        % Print Test
                        print_training_parameters(param_names,[nn_h D2 D3 D4 D5 D6])
                        
                        % Training
                        [train_results, test_results, time_results, record] = Trainer(...
                            data,network,train_set,net_set,alg_settings);
                        
                        % Test Results
                        fprintf('TRAINING:    RMSE average = %9.4f | SR (%%)  = %9.4f\n',train_results)
                        fprintf('TESTING:     RMSE average = %9.4f | SR (%%)  = %9.4f\n',test_results)
                        fprintf('ITERATIONS:  succeed      = %9.4f | all     = %9.4f\n',time_results(1:2))
                        fprintf('TIME (s):    succeed      = %9.4f | all     = %9.4f \n\n',time_results(3:4))
                        fprintf('*********************************************************\n\n')
                        if((criterionF >= 0 && test_results(2) > crit) ||...
                                (criterionF < 0 && test_results(1) < crit))
                            best_train = train_results;
                            best_test = test_results;
                            best_time = time_results;
                            bestD = [nn_h D2 D3 D4 D5 D6];
                            if(criterionF < 0)
                                crit = test_results(1);
                            else
                                crit = test_results(2);
                            end
                        end
                        
                        % Store Results
                        sweep_results(test_iter,1:2) = train_results(1:2);
                        sweep_results(test_iter,3:4) = test_results(1:2);
                        sweep_results(test_iter,5:6) = time_results([1 3]);
                        sweep_results(test_iter,7:10) = [nn_h type cell2mat(record(1)) cell2mat(record(2))];
                        sweep_results(test_iter,11:15) = [D2 D3 D4 D5 D6];
                        test_iter = test_iter+1;
                        
                        % Pause Diary
                        diary off
                    end
                end
            end
        end
    end
end

% Resume Diary
diary(logS);

if((criterionF >= 0 && crit > 0) || criterionF < 0)
    % Last Results Print
    fprintf('*********************************************************\n')
    fprintf('********************* FINAL RESULTS *********************\n')
    fprintf('*********************************************************\n\n')
    print_training_parameters(param_names,bestD)
    fprintf('TRAINING:    RMSE average = %9.4f | SR (%%)  = %9.4f\n',best_train)
    fprintf('TESTING:     RMSE average = %9.4f | SR (%%)  = %9.4f\n',best_test)
    fprintf('ITERATIONS:  succeed      = %9.4f | all     = %9.4f\n',best_time(1:2))
    fprintf('TIME (s):    succeed      = %9.4f | all     = %9.4f \n\n',best_time(3:4))
else
    % No successes
    fprintf('*********************************************************\n')
    fprintf('********************* NO  SUCCESSES *********************\n')
    fprintf('*********************************************************\n')
end

% Finish Diary
diary off

% Uncomment to play music when finished
% load handel
% sound(y,Fs)