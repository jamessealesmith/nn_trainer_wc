function [ topo, nloc, nn, nw] = prepTopo( type,network )
%  MLP ,network=>  ninp 3 4 2 1
%  SLP ,network=>  ninp 17 1
%  FCC ,network=>  ninp 1 1 1 1 1 1
%  BMLP,network=>  ninp 3 4 2 1
topo=[];
nl=length(network);
for i=2:nl                  %   for number of layers
    s=sum(network(1:i-1));      %   starting a new layer
    for j=1:network(i)          %   in each layer
        switch type
            case 1 % Connection across layers
                topo=[topo, s+j, 1:s];
            case 2 % No connection across layers
                topo=[topo, s+j, s-network(i-1)+1:s]; 
        end
    end
end

% Find number weights
nw = length(topo);

% Find nloc array
nmax=0; j=0;
for i=1:length(topo)
    if topo(i)>nmax
        nmax=topo(i);
        j=j+1; nloc(j)=i;
    end
end
nloc(j+1)=i+1;
nn = length(nloc)-1;

