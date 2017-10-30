function [iter,SSE,ww,tr_rec] = ebp_wc(desErr,maxIter,nn,act,gain,...
    no,nloc,topo,nw,ni,np,in,dout,ww,earlyF,alg_settings)
%% EBP algorithm
% Weight Compression: Compress weights to avoid neuron saturation
%

% Get learning rate and momentum term
c = alg_settings(1);
m = 0;
prev_delta_w = zeros(1,nw);

% Initial error estimate
error = calculateError(np,nn,ni,no,topo,nloc,in,dout,act,gain,ww);
SSE = error;    % Error matrix
iter = 1;       % Iteration Counter
if(SSE < desErr)
    return % Training Sucess
end

% Compression Variables 
M_RESET = -1;                        % flag to reset the value of momentum
prev_compress_error = error;         % hold for rmse
prev_compress_ww = ww;               % hold for ww
num_compress = 0;                    % number compressions
COMPRESS_OPTION = alg_settings(2);   % 1 = error not changing, 2 = by iteration
COMPRESS_T = alg_settings(3);        % error change threshold for option 1,
                                     % iteration interval for option 2
omega = alg_settings(4);
rho = alg_settings(5);

% Train Weights
for iter = 2:maxIter
    
    % Calculate gradient
    [gradient] = calculateGradient(np,nn,ni,no,nw,topo,...
        nloc,in,dout,act,gain,ww);
    
    % Update weights
    % Update Weights
    if(M_RESET > 0) % Check m reset flag
        delta_w = c * gradient';
        M_RESET = -1;
    else
        delta_w = (1-m) * c * gradient' + m * prev_delta_w;
    end
    prev_delta_w = delta_w;
    ww = ww + delta_w;
    error = calculateError(np,nn,ni,no,topo,nloc,in,dout,...
        act,gain,ww);
        
    % Update error matrix
    SSE(iter) = error;
    
    if(earlyF > 0 && SSE(iter) < desErr)
        break; %Sucess
    end
    
    if(iter == maxIter)
        if(~(error <= prev_compress_error))
            SSE(iter) = prev_compress_error;
            ww = prev_compress_ww;
        end
    else
        % Consider weight compression
       if((COMPRESS_OPTION == 1 && abs(SSE(iter)-SSE(iter-1))/SSE(iter-1) <= COMPRESS_T)||...
               (COMPRESS_OPTION == 2 && mod(iter,COMPRESS_T) == 0))
            if(~(error <= prev_compress_error))
                SSE(iter) = prev_compress_error;
                ww = prev_compress_ww;
                omega = omega / rho;
            else
                prev_compress_error = error;
                prev_compress_ww = ww;
                omega = omega * rho;
            end
            net_a = calculate_net_mean(np,nn,ni,topo,nloc,in,act,gain,ww);
            for n = 1:nn-1
                % Find weight indices
                s = nloc(n);
                f = nloc(n+1)-1;
                
                % Compress weights
                ww(s:f) = ww(s:f) * omega / (1 * gain(n) * net_a(n));                
            end
            M_RESET = 1;
            num_compress = num_compress + 1;
        end
    end
end

tr_rec{1} = num_compress;
    
end

