function algS = algDirectory( id )
% Return String cooresponding to algorithm being used
%
% Current Algorithms:
% 1 = nbn, 2 = nbn_wc,
% 3 = compress by error with saturating threshold, 4 = compress by error
% 5 = compress by iteration, 6  smart compress by error
%
% 11 = error isolation
%
% 21 = smart guess, 22 = cascading patterns
%
% 51 = eby, 52 = ebp compression

switch id
    case 1
        algS = 'nbn';
    case 2
        algS = 'nbn weight compression';        
    case 3
        algS = 'nbn random restarts';
    case 51
        algS = 'ebp';        
    case 52
        algS = 'ebp weight compression';        
    otherwise
        algS = '**!!!SANDBOX!!!**';
end

end

