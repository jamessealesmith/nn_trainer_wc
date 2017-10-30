function out=actFunc(n,net,act,gain)
%Output of Neuron
%

switch act(n)
    case 0, out = gain(n)*net;                          % linear neuron
    case 1, out = 1/(1+exp(-gain(n)*net));              % unipolar neuron
    case 2, out = tansig(gain(n)*net);                    % bipolar neuron
end;
% out=out+net*de;