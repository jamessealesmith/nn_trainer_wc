function [ outMat ] = forward(np,nn,ni,topo,nloc,in,...
    act,gain,ww)
% Calculate forward net for NN
%
for p = 1:np
    %Forward computation
    node_in(1:ni) = in(p, 1:ni);
    for n = 1:nn
        %For all neuron weights
        net = ww(nloc(n));
        for i=(nloc(n)+1):(nloc(n+1)-1)
            %Calculate net
            net = net + ww(i)*node_in(topo(i));
        end
        
        %Calculate output/slope
        [out,der(ni+n)] = actFunc_der(n,net,act,gain); 
        node_in(ni+n) = out;
    end
    outMat(p,:) = out;
    
end

end

