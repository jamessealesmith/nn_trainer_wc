function [ errorMat, derMat, netMat ] = errorBackProp(nn,act,gain,...
    no,nloc,topo,ni,np,in,dout,ww)
% Backpropagate Error to each neuron for each pattern. Store and save these
% errors

% Define variables
out=zeros(1,nn);        % inputs(ni) and outputs of nn neurons
der=zeros(1,nn);        % derivative of activation function of nn neurons
errorMat=zeros(np,nn);  % weight change

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
        
        % Calculate out/slope
        [out(n),der(ni+n)] = actFunc_der(n,net,act,gain);
        topo_id(ni+n) = out(n);
        derMat(p,n) = der(ni+n);
        netMat(p,n) = net;
    end
    
    % Back Error
    err_topo = zeros(1,ni+nn); % error corresponding to id in topo
    for i=nn:-1:1
        if(i > nn-no)
            errorMat(p,i) = dout(p,i-nn+no) - out(i);
        else
            errorMat(p,i) = err_topo(i+ni);
        end
        for j=nloc(i)+1:nloc(i+1)-1
            err_topo(topo(j))=err_topo(topo(j))+...
                der(ni+i)*ww(j)*errorMat(p,i);
        end;
    end;
end
end

