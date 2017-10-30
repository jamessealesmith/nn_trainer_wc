function [ gradient,hessian ] = calculateHessian(np,nn,ni,no,nw,topo,...
    nloc,in,dout,act,gain,ww)
% Calculate the Hessian and Gradient values
%

% Initialize
gradient = zeros(nw,1);
hessian = zeros(nw,nw);

% Perform Calculations
for p = 1:np
    % Forward computation
    topo_id(1:ni) = in(p, 1:ni);
    for n = 1:nn
        % For all neuron weights
        net = ww(nloc(n));
        for i=(nloc(n)+1):(nloc(n+1)-1)
            % Calculate net
            net = net + ww(i)*topo_id(topo(i));
        end
        
        % Calculate output/slope
        [out,der(ni+n)] = actFunc_der(n,net,act,gain);
        topo_id(ni+n) = out;        
    end
    
    % Backward Computatoin
    for k = 1:no
        % Output Parameters
        o = nn+ni-no+k;            % Location of output
        s = nloc(o-ni);            % Neuron weight location of output
        delo=zeros(1,nn+ni-no+1);  % Change in Output
        
        % Calculate error
        error = dout(p,k) - topo_id(o);
        
        % Jacobian row
        J = zeros(1, nw);  
        J(s) = -der(o); % Initial delta as slope
        
        % For the weights of output connected to other neurons
        for i = (s+1):(nloc(o+1-ni)-1) 
            % Jacobian row element
            J(i) = topo_id(topo(i))*J(s);
            
            % Multiple delta throught weight and sum backprop delta 
            delo(topo(i)) = delo(topo(i))-ww(i)*J(s);
        end
        
        % Backward computation for hidden nuerons in reverse order
        for n = 1:(nn-no)
            j = nn+ni-no + 1 - n;    %hidden node number
            s = nloc(j-ni);          %Neuron weight location
            J(s) = -der(j)*delo(j);  %Multiply delta by slope
            for i = (s+1):(nloc(j-ni+1)-1)   %for weights of hidden neuron
                % Jacobian row element
                J(i) = topo_id(topo(i))*J(s); 
                
                % Multiple delta throught weight and sum backprop delta 
                delo(topo(i)) = delo(topo(i)) - ww(i)*J(s);           
            end
        end

        
        gradient = gradient + J'*error;
        hessian = hessian + J'*J;
        
%         temp_delta_w = -1*((J'*J+0.01*eye(nw))\J'*error)';
    end
end


end

