function [ net_a ] = calculate_net_mean(np,nn,ni,topo,nloc,in,...
    act,gain,ww)
% Calculate error of NN and return mean net of each neuron
%

% Initialize net array
net_a = zeros(1,nn);

% Add Error for each pattern
for p = 1:np
    % Forward computation
    node_in(1:ni) = in(p, 1:ni);
    for n = 1:nn
        % For all neuron weights
        net = ww(nloc(n));
        for i=(nloc(n)+1):(nloc(n+1)-1)
            % Calculate net
            net = net + ww(i)*node_in(topo(i));
            net_a(n) = net_a(n) + abs(net);
        end
        
        % Calculate output/slope
        [out] = actFunc(n,net,act,gain);
        node_in(ni+n) = out;        
    end
end

net_a = net_a / np;

end

