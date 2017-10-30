function statsGraph(statMat,iterStore,maxIter,ntrials,nn,success_store)
% Graph statistical output of nbn training
for n = 1:nn
    
    % calculatoin
    ymax = max(max(statMat(:,n,:)));
    
    % create figure
    f = figure;
    set(f, 'units','normalized','outerposition',[1/6+1/40*n 1/16 2/3 7/8]);
    
    % plot settings
    ystr = 'Stat';
    xstr = 'Iterations';
    alw = 1;    % AxesLineWidth
    fsz = 20;      % Fontsize
    
    % plot successes
    subplot(2,1,1)
    title(sprintf('Success for Neuron %d',n));
    ylabel(ystr)
    xlabel(xstr)
    xlim([0 maxIter])
    ylim([0 ymax*1.5])
    set(gca, 'FontSize', fsz, 'LineWidth', alw); %<- Set properties
    grid on;
    
    % plot failures
    subplot(2,1,2)
    title(sprintf('Failure for Neuron %d',n));
    ylabel(ystr)
    xlabel(xstr)
    ylim([0 ymax*1.5])
    set(gca, 'FontSize', fsz, 'LineWidth', alw); %<- Set properties
    grid on;
    
    start_suc = [];
    total_suc = [];
    end_suc = [];
    start_fail = [];
    total_fail = [];
    end_fail = [];
    for tr = 1:ntrials
        if(success_store(tr) > 0)
            % plot successes
            subplot(2,1,1)
            hold on
            plot(1:iterStore(tr),squeeze(statMat(tr,n,1:iterStore(tr))))
            start_suc = [start_suc statMat(tr,n,2)];
            total_suc = [total_suc mean(statMat(tr,n,:))];
            end_suc = [end_suc statMat(tr,n,iterStore(tr))];
        else
            %plot failures
            subplot(2,1,2)
            hold on
            plot(1:iterStore(tr),squeeze(statMat(tr,n,1:iterStore(tr))))
            start_fail = [start_fail statMat(tr,n,2)];
            total_fail = [total_fail mean(statMat(tr,n,:))];
            end_fail = [end_fail statMat(tr,n,iterStore(tr))];
        end
    end
    
    % print statistics for success
    subplot(2,1,1)
    start_mean = mean(start_suc);
    start_median = median(start_suc);
    start_std = std(start_suc);
    
    end_mean = mean(total_suc);
    end_median = median(total_suc);
    end_std = std(total_suc);
    
    total_mean = mean(end_suc);
    total_median = median(end_suc);
    total_std = std(end_suc);
    
    label = sprintf('START:\nEND:\nTOTAL:');
    text(maxIter/4,1.25*ymax,label,'FontSize',12,'FontWeight','bold')
    txt = sprintf('mean = %8.6f, median = %8.6f, std = %8.6f\nmean = %8.6f, median = %8.6f, std = %8.6f\nmean = %8.6f, median = %8.6f, std = %8.6f'...
        ,start_mean,start_median,start_std...
        ,end_mean,end_median,end_std...
        ,total_mean,total_median,total_std);
    text(maxIter*(1/4+0.07),1.25*ymax,txt,'FontSize',12,'FontWeight','bold')
    
    
    % print statistics for fail
    subplot(2,1,2)
    start_mean = mean(start_fail);
    start_median = median(start_fail);
    start_std = std(start_fail);
    
    end_mean = mean(total_fail);
    end_median = median(total_fail);
    end_std = std(total_fail);
    
    total_mean = mean(end_fail);
    total_median = median(end_fail);
    total_std = std(end_fail);
    
    label = sprintf('START:\nEND:\nTOTAL:');
    text(maxIter/4,1.25*ymax,label,'FontSize',12,'FontWeight','bold')
    txt = sprintf('mean = %8.6f, median = %8.6f, std = %8.6f\nmean = %8.6f, median = %8.6f, std = %8.6f\nmean = %8.6f, median = %8.6f, std = %8.6f'...
        ,start_mean,start_median,start_std...
        ,end_mean,end_median,end_std...
        ,total_mean,total_median,total_std);
    text(maxIter*(1/4+0.07),1.25*ymax,txt,'FontSize',12,'FontWeight','bold')
    
end

end

