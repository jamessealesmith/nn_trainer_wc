%% Prepare Workspace
function logS = prepare_workspace()

% get name of log file
formatOut = 'mm_dd_yy';
logS = strcat('Logs/',datestr(now,formatOut));

% add folders to path
addpath('TrainingAlgorithms','BackpropFunctions','SupportFunctions',...
    'Data','CustomFunctions');
warning off
end
