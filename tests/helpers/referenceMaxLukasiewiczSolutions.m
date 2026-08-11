function expected = referenceMaxLukasiewiczSolutions(a, b, inequalities)
%REFERENCEMAXLUKASIEWICZSOLUTIONS Exhaustive max-Lukasiewicz oracle.
    if nargin < 3
        inequalities = 0;
    end

    a = double(a);
    b = double(b(:));
    criticalValues = cell(1, size(a, 2));
    for j = 1:size(a, 2)
        levels = min(1, 1 - a(:, j) + b);
        criticalValues{j} = unique([0; levels; 1]).';
    end

    expected = referenceExtremalSolutions( ...
        'maxlukasiewicz', a, b, inequalities, criticalValues);
end
