%% Parameter Sweep
%
% Prepare Workspace
clear all; close all; clc;
logS = prepare_workspace();

%% User Input

% ***** Select data: *****
dataS = 'spiral.dat';

% ***** Select algorithm: *****
% 1 = nbn, 2 = nbn_wc, 3 = nbn_rr
% 51 = ebp, 52 = ebp_wc
% 0 = sandbox!
alg1 = 1;
param_names1 = [];
alg_settings1 = [];

alg2 = 2;
param_names2 = {'wc_setting','beta','omega','rho'};
alg_settings2 = [1 1E-4 0.1 1.1];
    
% ***** Set Network Parameters: *****
%  MLP ,hidden network=>  3 4 2 1
%  SLP ,hidden network=>  17 1
%  FCC ,hidden network=>  1 1 1 1 1 1
%  BMLP,hidden network=>  3 4 2 1
hidden_network = [ones(1,9)];

% 1 = connections accross layers
% 2 = no connections accross layers (MLP)
type = 1;  

% Activation, 0 = linear, 1 = unipolar, 2 = bipolar
actH = 2;        % activation of hidden layer neurons
actF = 0;        % activation of output neuron

% Other
no = 1;          % Number outputs     
gainMag = 1.0;

% ***** Set Training Parameters: *****
desErr = 0.1;                   % Desired Error
maxIter = 1000;                   % Maximum Iterations
ntrials = 100;                   % Number of training trials
train_per = 1.0;                   % Percent training data, 1 = train all
randF = -1;                      % > 0 randomly permutates dataset
normF = 1;                       % > 0 = normalize data
earlyF = 1;                      % > 0 = stop if reach desired error
nhF = -1;                        % > 0, Nguyen and Widrow weight initialization
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
train_set1 = {alg1,desErr,maxIter,ntrials,train_per,normF,earlyF,batchF,nhF};
train_set2 = {alg2,desErr,maxIter,ntrials,train_per,normF,earlyF,batchF,nhF};
nn_h = sum(hidden_network); % Number of hidden neurons
network = [hidden_network no];
net_set = {type,actH,actF,gainMag}; % Network settings

% Start Diary
diary(logS);

% Title Run
c = clock;
fprintf('\n\n\n\n\n\n\n\n\n\n')
fprintf('%s\n',datestr(datenum(c(1),c(2),c(3),c(4),c(5),c(6))))
fprintf('DEMO 1 - SPIRALS\n');
fprintf('Data - %s\n',dataS);
fprintf('Test Parameters:\nDE = %f\nMax Iter = %d\nTrials = %d\n\n'...
    ,desErr,maxIter,ntrials);

%% Begin Training
fprintf('******************** NBN ********************\n\n')

% Print Test
print_training_parameters(['hidden neurons' param_names1],[nn_h alg_settings1])

% Training
[train_results, test_results, time_results, record] = Trainer(...
    data,network,train_set1,net_set,alg_settings1);

% Test Results
fprintf('TRAINING:    RMSE average = %9.4f | SR (%%)  = %9.4f\n',train_results)
fprintf('TESTING:     RMSE average = %9.4f | SR (%%)  = %9.4f\n',test_results)
fprintf('ITERATIONS:  succeed      = %9.4f | all     = %9.4f\n',time_results(1:2))
fprintf('TIME (s):    succeed      = %9.4f | all     = %9.4f \n\n',time_results(3:4))

% Store Results
sweep_results(1,1:2) = train_results(1:2);
sweep_results(1,3:4) = test_results(1:2);
sweep_results(1,5:6) = time_results([1 3]);
sweep_results(1,7:10) = [nn_h type cell2mat(record(1)) cell2mat(record(2))];
if(size(alg_settings1,2) > 0); sweep_results(1,11:11+size(alg_settings1,2) - 1) = alg_settings; end;

fprintf('******************** NBN WEIGHT COMPRESSION ********************\n\n')

% Print Test
print_training_parameters(['hidden neurons' param_names2],[nn_h alg_settings2])

% Training
[train_results, test_results, time_results, record] = Trainer(...
    data,network,train_set2,net_set,alg_settings2);

% Test Results
fprintf('TRAINING:    RMSE average = %9.4f | SR (%%)  = %9.4f\n',train_results)
fprintf('TESTING:     RMSE average = %9.4f | SR (%%)  = %9.4f\n',test_results)
fprintf('ITERATIONS:  succeed      = %9.4f | all     = %9.4f\n',time_results(1:2))
fprintf('TIME (s):    succeed      = %9.4f | all     = %9.4f \n\n',time_results(3:4))
fprintf('*********************************************************\n\n')

% Store Results
sweep_results(2,1:2) = train_results(1:2);
sweep_results(2,3:4) = test_results(1:2);
sweep_results(2,5:6) = time_results([1 3]);
sweep_results(2,7:10) = [nn_h type cell2mat(record(1)) cell2mat(record(2))];
if(size(alg_settings2,2) > 0); sweep_results(2,11:11+size(alg_settings2,2) - 1) = alg_settings2; end;


% Finish Diary
diary off

load handel
sound(y,Fs)