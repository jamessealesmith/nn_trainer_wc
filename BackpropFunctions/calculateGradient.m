function [ gradient] = calculateGradient(np,nn,ni,no,nw,topo,...
    nloc,in,dout,act,gain,ww)
% Calculate the Gradient values
%

% Initialize
gradient = zeros(nw,1);

% Perform calculations
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
    
    % Backward computation
    delta=zeros(1,nn+ni); % delta_w = delta*x
    for i = nn-no+1:nn
        delta(ni+i) = der(ni+i)*(dout(p,i-nn+no) - topo_id(ni+i));
    end
    for i = nn:-1:1
        for j = nloc(i)+1:nloc(i+1)-1
            delta(topo(j)) = delta(topo(j)) + der(topo(j))*ww(j)*delta(ni+i);
        end
    end
    
    % Calculate gradient
    for i = 1:nn
        gradient(nloc(i)) = gradient(nloc(i)) + delta(ni+i);
        for j = (nloc(i)+1):(nloc(i+1)-1)
            gradient(j) = gradient(j) + delta(ni+i)*topo_id(topo(j));
        end
    end
end

end

