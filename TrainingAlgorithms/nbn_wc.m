function [iter,SSE,ww,tr_rec] = nbn_wc(desErr,maxIter,nn,act,gain,...
    no,nloc,topo,nw,ni,np,in,dout,ww,earlyF,alg_settings)
%% NBN algorithm
% Weight Compression: Compress weights to avoid neuron saturation
%

% Mu value for nbn weight adjustment
muStart = 0.001; %Starting Constant
mu = muStart;   %Starting Value
muMax = 10^15;  %Max
muMin = 10^-15; %Min
scale = 10;     %Mu Scale

% Other variables
I = eye(nw);   % Identity Matrix

% Initial error estimate
error = calculateError(np,nn,ni,no,topo,nloc,in,dout,act,gain,ww);
errorT = error; % Error that next iteration will be compared with
SSE = error;    % Error matrix
iter = 1;       % Iteration Counter
if(SSE < desErr)
    return % Training Success
end

% Compression Variables
MU_RESET = -1;                       % flag to reset the value of "mu"  
prev_compress_error = error;         % hold for rmse
prev_compress_ww = ww;               % hold for ww
num_compress = 0;                    % number compressions
COMPRESS_OPTION = alg_settings(1);   % 1 = error not changing, 2 = by iteration
COMPRESS_T = alg_settings(2);        % error change threshold for option 1,
                                     % iteration interval for option 2
omega = alg_settings(3);
rho = alg_settings(4);

% Train Weights
for iter = 2:maxIter
    
    % Calculate Gradient/Hessian
    [gradient,hessian] = calculateHessian(np,nn,ni,no,...
        nw,topo,nloc,in,dout,act,gain,ww);
    
    % Update Weights
    if(MU_RESET > 0) % Check mu reset flag
        ww = ww - ((hessian+mu*I)\gradient)';
        error = calculateError(np,nn,ni,no,topo,nloc,in,dout,act,gain,ww);
        MU_RESET = -1;
    else
        ww_backup = ww;
        jw = 0;
        while 1
            % Change in Weight
            delta_w = -1*((hessian+mu*I)\gradient)';
            ww = ww_backup + delta_w;
            
            % Calculate error
            error = calculateError(np,nn,ni,no,topo,nloc,in,dout,act,gain,ww);
            
            % Update Mu
            if error <= errorT
                if mu > muMin
                    mu = mu/scale;
                end
                break
            end
            if mu < muMax
                mu = mu*scale;
            end
            jw = jw + 1;
            if jw > 30
                ww=ww_backup;
                error = calculateError(np,nn,ni,no,topo,nloc,in,dout,act,gain,ww);
                break
            end
        end
    end
    
    % Update Error Matrix
    SSE(iter) = error;
    errorT = error;    
    
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
            mu = muStart;
            MU_RESET = 1;
            num_compress = num_compress + 1;
        end
    end
end

tr_rec{1} = num_compress;


