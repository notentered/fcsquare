function expected = referenceGodelSolutions(a, b, inequalities)
%REFERENCEGODELSOLUTIONS Finite exhaustive oracle for min-Godel systems.
    if nargin < 3
        inequalities = 0;
    end

    a = double(a);
    b = double(b(:));
    criticalValues = cell(1, size(a, 2));
    for j = 1:size(a, 2)
        criticalValues{j} = unique([0; a(:, j); b; 1]).';
    end

    expected = referenceExtremalSolutions( ...
        'godel', a, b, inequalities, criticalValues);
end
