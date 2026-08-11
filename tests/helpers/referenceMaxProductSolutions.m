function expected = referenceMaxProductSolutions(a, b, inequalities)
%REFERENCEMAXPRODUCTSOLUTIONS Finite exhaustive oracle for max-product.
    if nargin < 3
        inequalities = 0;
    end

    a = double(a);
    b = double(b(:));
    criticalValues = cell(1, size(a, 2));
    for j = 1:size(a, 2)
        positive = a(:, j) > 0;
        ratios = b(positive) ./ a(positive, j);
        ratios = ratios(ratios >= 0 & ratios <= 1);
        criticalValues{j} = unique([0; ratios; 1]).';
    end

    expected = referenceExtremalSolutions( ...
        'maxprod', a, b, inequalities, criticalValues);
end
