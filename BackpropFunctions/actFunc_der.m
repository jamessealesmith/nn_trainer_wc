function [ out,der ] = actFunc_der(n,net,act,gain)
%Output of Neuron
%

switch act(n)
    case 0, out = gain(n)*net;                % linear neuron
        der = gain(n);                         
    case 1, out = 1/(1+exp(-gain(n)*net));    % unipolar neuron
        der = gain(n)*(1-out)*out;             
    case 2, out = tansig(gain(n)*net);          % bipolar neuron
        der = gain(n)*(1-out*out);                   
end;