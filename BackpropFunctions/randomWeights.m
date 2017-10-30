function [ ww ] = randomWeights( nw )
%Initialize random starting weights between -1...1,
% NOT including 0
ww = rands(1,nw);
% ww = 2*rand(1,nw)-1;
% for i = 1:nw
%     while ww(i) == 0
%         ww(i) = 2*rand()-1;
%     end
% end
end

