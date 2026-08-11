classdef fuzzySystemMaxEpsilonTest < matlab.unittest.TestCase
    % Literature-derived and exact-oracle tests for max-epsilon systems.

    properties (Constant)
        DevelopmentRepetitions = 10
    end

    methods (Test)
        function testLiteratureDerivedEquationExample(testCase)
            fixture = testCase.applyFixture(fuzzySystemLiteratureFixture);
            ex = fixture.MaxEpsilon;
            testCase.verifyEqual(maxepsilon(ex.a, ex.witness), ex.b, ...
                'AbsTol', 1e-12, ex.source);
            system = fuzzySystem('maxepsilon', ex.a, ex.b, [], true);

            system.solve_inverse();

            testCase.verifyTrue(system.x.exist, ex.source);
            testCase.verifyEqual(double(system.x.gr), double(ex.greatest), ...
                'AbsTol', 1e-12, ex.source);
            testCase.verifyEqual(canonical(system.x.low), canonical(ex.minimal), ...
                'AbsTol', 1e-12, ex.source);
        end

        function testStrictBoundaryAndImpossibleSystem(testCase)
            strict = fuzzySystem('maxepsilon', ...
                fuzzyMatrix(0.8), fuzzyMatrix(0.5), [], true, 1);
            strict.solve_inverse();
            testCase.verifyTrue(strict.x.exist);
            testCase.verifyEqual(double(strict.x.low), 0.8);
            testCase.verifyFalse(strict.x.low_inclusive);
            testCase.verifyEqual(double(maxepsilon( ...
                strict.a, fuzzyMatrix(0.8))), 0);
            testCase.verifyGreaterThanOrEqual(double(maxepsilon( ...
                strict.a, fuzzyMatrix(0.8 + 1e-9))), 0.5);

            impossible = fuzzySystem('maxepsilon', ...
                fuzzyMatrix(1), fuzzyMatrix(0.5), [], true, 1);
            impossible.solve_inverse();
            testCase.verifyFalse(impossible.x.exist);
            testCase.verifyEqual(impossible.x.contradict(:).', 1);
        end

        function testEquationAndInequalitiesAgainstIndependentOracle(testCase)
            for repetition = 1:testCase.DevelopmentRepetitions
                rng(7400 + repetition, 'twister');
                a = fuzzyMatrix(randi([0 4], 2, 3) / 4);
                witness = fuzzyMatrix(randi([0 4], 3, 1) / 4);
                b = maxepsilon(a, witness);

                for inequalities = [-1 0 1]
                    expected = referenceMaxEpsilonSolutions(a, b, inequalities);
                    actual = fuzzySystem( ...
                        'maxepsilon', a, b, [], true, inequalities);

                    context = sprintf(['max-epsilon oracle mismatch\n' ...
                        'repetition=%d, inequalities=%d\nA=%s\nB=%s'], ...
                        repetition, inequalities, mat2str(double(a)), ...
                        mat2str(double(b)));
                    verifyNoException(testCase, @() actual.solve_inverse(), context);
                    testCase.verifyEqual(actual.x.exist, expected.exist, context);
                    if expected.exist
                        testCase.verifyEqual(canonical(actual.x.gr), ...
                            canonical(expected.gr), 'AbsTol', 1e-12, context);
                        if inequalities == 1
                            testCase.verifyTrue(isfield(actual.x, 'low_inclusive'), ...
                                ['Open max-epsilon bounds require low_inclusive.' newline context]);
                            testCase.verifyEqual( ...
                                canonicalBoxes(actual.x.low, actual.x.low_inclusive), ...
                                canonicalBoxes(expected.low, expected.low_inclusive), ...
                                'AbsTol', 1e-12, context);
                            verifyInteriorPoints(testCase, a, b, actual.x, context);
                        else
                            testCase.verifyEqual(canonical(actual.x.low), ...
                                canonical(expected.low), 'AbsTol', 1e-12, context);
                        end
                    end
                end
            end
        end
    end
end

function result = canonical(solutions)
    result = sortrows(double(solutions).').';
end

function result = canonicalBoxes(lower, inclusive)
    combined = [double(lower); double(inclusive)];
    result = sortrows(combined.').';
end

function verifyInteriorPoints(testCase, a, b, solution, context)
    tolerance = 1e-9;
    for k = 1:size(solution.low, 2)
        interior = double(solution.low(:, k));
        openCoordinates = ~solution.low_inclusive(:, k);
        interior(openCoordinates) = min(1, ...
            interior(openCoordinates) + tolerance);
        obtained = double(maxepsilon(a, fuzzyMatrix(interior)));
        testCase.verifyGreaterThanOrEqual( ...
            obtained, double(b) - 1e-12, context);
    end
end
