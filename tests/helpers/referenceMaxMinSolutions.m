function expected = referenceMaxMinSolutions(a, b, inequalities)
%REFERENCEMAXMINSOLUTIONS Finite exhaustive oracle for max-min systems.
    if nargin < 3
        inequalities = 0;
    end
    criticalValues = unique([0; double(b(:)); 1]).';
    expected = referenceExtremalSolutions( ...
        'maxmin', a, b, inequalities, criticalValues);
end
