function [iter,SSE,ww] = ebp(desErr,maxIter,nn,act,gain,...
    no,nloc,topo,nw,ni,np,in,dout,ww,earlyF,alg_settings)
%% EBP algorithm
%

% Get learning rate and momentum term
c = alg_settings(1);
m = alg_settings(2);
prev_delta_w = zeros(1,nw);

% Initial error estimate
error = calculateError(np,nn,ni,no,topo,nloc,in,dout,act,gain,ww);
SSE = error;    % Error matrix
iter = 1;       % Iteration Counter
if(SSE < desErr)
    return % Training Sucess
end


% Train Weights
for iter = 2:maxIter
    
    % Calculate gradient
    [gradient] = calculateGradient(np,nn,ni,no,nw,topo,...
        nloc,in,dout,act,gain,ww);
    
    % Update weights
    delta_w = (1-m) * c * gradient' + m * prev_delta_w;
    prev_delta_w = delta_w;
    ww = ww + delta_w;
    error = calculateError(np,nn,ni,no,topo,nloc,in,dout,...
        act,gain,ww);
        
    % Update error matrix
    SSE(iter) = error;
    
    if(earlyF > 0 && SSE(iter) < desErr)
        break; %Sucess
    end
    
end


