function expected = referenceMinMaxSolutions(a, b, inequalities)
%REFERENCEMINMAXSOLUTIONS Finite exhaustive oracle for min-max systems.
    if nargin < 3
        inequalities = 0;
    end
    criticalValues = unique([0; double(b(:)); 1]).';
    expected = referenceExtremalSolutions( ...
        'minmax', a, b, inequalities, criticalValues);
end
