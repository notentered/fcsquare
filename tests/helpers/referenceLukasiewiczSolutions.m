function expected = referenceLukasiewiczSolutions(a, b, inequalities)
%REFERENCELUKASIEWICZSOLUTIONS Exhaustive min-Lukasiewicz oracle.
    if nargin < 3
        inequalities = 0;
    end

    a = double(a);
    b = double(b(:));
    criticalValues = cell(1, size(a, 2));
    for j = 1:size(a, 2)
        levels = max(0, a(:, j) + b - 1);
        criticalValues{j} = unique([0; levels; 1]).';
    end

    expected = referenceExtremalSolutions( ...
        'lukasiewicz', a, b, inequalities, criticalValues);
end
