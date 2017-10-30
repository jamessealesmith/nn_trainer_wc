function [ ww ] = weights_nw( ww, nloc, network, type, act)
%Initialize weights using the Nguyen and Widrow method

% Find limits based on activation function
if(act == 0)
    return
elseif(act == 1)
    out_r = [0 1];
elseif(act == 2)
    out_r = [-1 1];
end
in_r = [-2 2];

% Process inputs
nl=length(network)-1;

% Start global neuron index
n_g = 0;

for i=2:nl  % for number of layers
    % number inputs
    if(type == 1)
        ni = sum(network(1:i-1));
    elseif(type == 2)
        ni = network(i-1);
    end
    
    % get scale value
    nh = network(i);   % number hidden neurons
    scale = 0.7 * nh^(1 / ni); % scale value by nw
    
    % spread out biases
    if (nh == 1)
        b = 0;
    else
        b = linspace(-1,1,nh); 
    end
    
    for n = 1:network(i) 
         n_g = n_g + 1;
         s = nloc(n_g)+1;
         f = nloc(n_g+1)-1;
         mag = sqrt(sum(ww(s:f).^2));
         ww(s:f) = ww(s:f) * scale / mag; % weights
         ww(s-1) = b(n) * sign(ww(s-1)) * scale; % bias weight
         
         % Adjust for activation
         ww(s:f) = ww(s:f) * 0.5 * (in_r(2) - in_r(1));
         ww(s-1) = ww(s-1) * 0.5 * (in_r(2) - in_r(1) + in_r(2) + in_r(1));
    end
      
end
end