function print_training_parameters(names,p)
fprintf('%s = %g',names(1),p(1));
for s = 2:size(names,2)
    fprintf(', %s = %g',names(s),p(s));
end
fprintf('\n\n');
end

