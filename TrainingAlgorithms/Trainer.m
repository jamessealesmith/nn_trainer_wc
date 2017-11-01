function [train_results, test_results, time_results, record] = Trainer(...
    data,network,train_set,net_set,alg_settings)
%% Training Software

% Process settings
[alg,desErr,maxIter,ntrials,train_per,normF,earlyF,batchF,nhF] = train_set{:};
[type,actH,actF,gainMag] = net_set{:};

% Figure for plotting RMSE_tr
if (batchF > 1 && batchF < 4)
    figure
end

% Process inputs
[ ti,td,tnp,ti_tst,td_tst,tnp_tst,ni,no,network] = process_inputs(...
    data,network,train_per,normF);

% Prepare network
[topo,nloc,nn,nw] = prepTopo(type,network);
gain = gainMag*ones(1,nn);
act = [actH*ones(1,nn-no) actF*ones(1,no)];

% Scale desired error to compare with TE
desErrSSE_tr = tnp*desErr^2;

% Output variables
num_suc_tr = 0;    % Number successful trials
num_suc_tst = 0;
ave_tim_suc = 0;   % Average time per trial
ave_tim_all = 0;
ave_iter_suc = 0;   % Average iterations per trial
ave_iter_all = 0;
ave_RMSE_tr = 0;   % Average RMSE per trial
ave_RMSE_tst = 0;

% Training record
ave_compress = 0;
best_ww = 0;
best_rmse = -1;

for tr = 1:ntrials
    tic;
    
    % Initialize random weights
    if(nhF > 0)
        ww = weights_nw( ww, nloc, network, type, actH);
    else
        ww = randomWeights(nw);
    end
    
    % Train Weights
    switch alg
        case 0
            % ebp
            [iter,SSE_tr,ww] = ebp(desErrSSE_tr,maxIter,nn,act,gain,...
                no,nloc,topo,nw,ni,tnp,ti,td,ww,earlyF,alg_settings);
        case 1
            % nbn
            [iter,SSE_tr,ww] = nbn(desErrSSE_tr,maxIter,nn,act,gain,...
                no,nloc,topo,nw,ni,tnp,ti,td,ww,earlyF);
        case 2
            % nbn weight compression
            [iter,SSE_tr,ww, tr_rec] = nbn_wc(desErrSSE_tr,maxIter,nn,act,gain,...
                no,nloc,topo,nw,ni,tnp,ti,td,ww,earlyF,alg_settings);
        case 3
            % nbn random restarts
            [iter,SSE_tr,ww] = nbn_rr(desErrSSE_tr,maxIter,nn,act,gain,...
                no,nloc,topo,nw,ni,tnp,ti,td,ww,earlyF,alg_settings);
        case 51
            % ebp
            [iter,SSE_tr,ww] = ebp(desErrSSE_tr,maxIter,nn,act,gain,...
                no,nloc,topo,nw,ni,tnp,ti,td,ww,earlyF,alg_settings);
        case 52
            % ebp weight compression
            [iter,SSE_tr,ww, tr_rec] = ebp_wc(desErrSSE_tr,maxIter,nn,act,gain,...
                no,nloc,topo,nw,ni,tnp,ti,td,ww,earlyF,alg_settings);
    end
    
    % Training results
    ave_tim_all = (ave_tim_all * (tr-1) + toc) / (tr);
    RMSE_tr = sqrt(SSE_tr/tnp);
    if(RMSE_tr(end) < desErr)
        num_suc_tr = num_suc_tr + 1;
        ave_iter_suc = (ave_iter_suc * (num_suc_tr-1) + iter) / (num_suc_tr);
        ave_tim_suc = (ave_tim_suc * (num_suc_tr-1) + toc) / (num_suc_tr);
    end
    ave_iter_all = (ave_iter_all * (tr-1) + iter) / (tr);
    
    % Plot RMSE training
    if (batchF > 1 && batchF < 4)
        hold on;
        plot(1:iter,RMSE_tr);
    end
    ave_RMSE_tr = (ave_RMSE_tr * (tr-1) + RMSE_tr(end)) / (tr);
    
    % Testing results
    SSE_tst = calculateError(tnp_tst,nn,ni,no,topo,nloc,ti_tst,td_tst,act,gain,ww);
    RMSE_tst = sqrt(SSE_tst/tnp_tst);
    if(RMSE_tst < desErr)
        num_suc_tst = num_suc_tst + 1;
    end
    if(RMSE_tst < best_rmse || best_rmse < 0)
        best_rmse = RMSE_tst;
        best_ww = ww;
    end
    ave_RMSE_tst = (ave_RMSE_tst * (tr-1) + RMSE_tst) / (tr);
    
    % Print trial results
    if (batchF > 0)
        fprintf('Trial %2d: RMSE_train = %6.4f,RMSE_test = %6.4f\n',...
            tr,RMSE_tr(end),RMSE_tst)
    end
    
    % record
    if(alg == 2 || alg == 52)
        ave_compress = (ave_compress*(tr-1) + cell2mat(tr_rec(1))) / tr;
    end
end

% record final
record{1} = ave_compress;
record{2} = best_rmse;
record{3} = best_ww;

% Final statistics
SR_tr = num_suc_tr * 100 / ntrials;
SR_tst = num_suc_tst * 100 / ntrials;
train_results = [ave_RMSE_tr SR_tr];
test_results = [ave_RMSE_tst SR_tst];
time_results = [ave_iter_suc ave_iter_all ave_tim_suc ave_tim_all];

% Label figure
if (batchF > 1)
    ylabel('RMSE train')
    xlabel('Iterations')
    ylim([0 (2)])
end

end

