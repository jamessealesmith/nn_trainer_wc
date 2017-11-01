function print_training_parameters(names,p)
fprintf('%s = %g',char(names(1)),p(1));
for s = 2:size(p,2)
    fprintf(', %s = %g',char(names(s)),p(s));
end
fprintf('\n\n');
end

