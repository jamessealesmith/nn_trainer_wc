function [ ww] = compress_weights(netMat,n,ww,nloc,gain,alpha)

SETTINGS = 1;

switch SETTINGS
    case 1
        % Calculate mean of NETs
        netMean = mean(abs(netMat(:,n)));
        
        % Find weight indices
        s = nloc(n);
        f = nloc(n+1)-1;
        
        % Shrink weights
        ww(s:f) = ww(s:f) * alpha / (1 * gain(n) * netMean);
        
end
end

