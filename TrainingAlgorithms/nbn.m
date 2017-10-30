function [iter,SSE,ww] = nbn(desErr,maxIter,nn,act,gain,...
    no,nloc,topo,nw,ni,np,in,dout,ww,earlyF)
%% NBN algorithm
%

% Alpha value for nbn weight adjustment
mu = 0.001;      %Starting
muMax = 10^15;  %Max
muMin = 10^-15; %Min
scale = 10;     %Mu Scale

% Other variables
I = eye(nw);   % Identity Matrix

% Initial error estimate
error = calculateError(np,nn,ni,no,topo,nloc,in,dout,act,gain,ww);
SSE = error;
iter = 1;
if(SSE(iter) < desErr)
    return;
end

% Train Weights
for iter = 2:maxIter
    
    % Update weights
    [gradient,hessian] = calculateHessian(np,nn,ni,no,nw,topo,nloc,in,...
        dout,act,gain,ww);
    ww_backup = ww;
    jw = 0;
    while 1
        % Change in Weight
        delta_w = -1*((hessian+mu*I)\gradient)';
        ww = ww_backup + delta_w;
        
        % Calculate error
        error = calculateError(np,nn,ni,no,topo,nloc,in,dout,act,gain,ww);
        
        % Update Mu
        if error <= SSE(iter-1)
            if mu > muMin
                mu = mu/scale;
            end
            break;
        end
        if mu < muMax
            mu = mu*scale;
        end
        jw = jw + 1;
        if jw > 30
            ww=ww_backup;
            error = calculateError(np,nn,ni,no,topo,nloc,in,dout,act,gain,ww);
            break;
        end
    end
    
    % Update Error Matrix
    SSE(iter) = error;
    
    if(earlyF > 0 && SSE(iter) < desErr)
        break;
    end
end


