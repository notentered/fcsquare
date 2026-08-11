function expected = referenceGoguenSolutions(a, b, inequalities)
%REFERENCEGOGUENSOLUTIONS Finite exhaustive oracle for min-Goguen systems.
    if nargin < 3
        inequalities = 0;
    end

    a = double(a);
    b = double(b(:));
    criticalValues = cell(1, size(a, 2));
    for j = 1:size(a, 2)
        criticalValues{j} = unique([0; a(:, j) .* b; 1]).';
    end

    expected = referenceExtremalSolutions( ...
        'goguen', a, b, inequalities, criticalValues);
end
