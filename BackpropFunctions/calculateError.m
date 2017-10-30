function [ error ] = calculateError(np,nn,ni,no,topo,nloc,in,...
    dout,act,gain,ww)
%Calculate error of NN
%

%Initialize Error
error = 0;

%Add Error for each Pattern
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
    
    %For all outputs
    for k = 1:no
        %Calculate error
        error = error + (dout(p,k) - node_in(nn+ni-no+k))^2;
    end
end

end

