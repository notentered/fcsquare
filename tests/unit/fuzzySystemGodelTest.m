classdef fuzzySystemGodelTest < matlab.unittest.TestCase
    % Deterministic and exhaustive-oracle tests for min-Godel systems.

    properties (Constant)
        DevelopmentRepetitions = 10
    end

    methods (Test)
        function testLiteratureDerivedEquationExample(testCase)
            fixture = testCase.applyFixture(fuzzySystemLiteratureFixture);
            ex = fixture.Godel;
            system = fuzzySystem('godel', ex.a, ex.b, [], true);

            system.solve_inverse();

            testCase.verifyTrue(system.x.exist, ex.source);
            testCase.verifyEqual(double(system.x.low), double(ex.least), ...
                'AbsTol', 1e-12, ex.source);
            testCase.verifyEqual(canonical(system.x.gr), canonical(ex.maximal), ...
                'AbsTol', 1e-12, ex.source);
        end

        function testOneBoundaryAndInconsistentSystem(testCase)
            oneBoundary = fuzzySystem('godel', ...
                fuzzyMatrix([0.4 0.8]), fuzzyMatrix(1), [], true);
            oneBoundary.solve_inverse();
            testCase.verifyTrue(oneBoundary.x.exist);
            testCase.verifyEqual(double(oneBoundary.x.low), [0.4; 0.8]);
            testCase.verifyEqual(double(oneBoundary.x.gr), [1; 1]);

            inconsistent = fuzzySystem('godel', ...
                fuzzyMatrix([0.2 0.3]), fuzzyMatrix(0.5), [], true);
            inconsistent.solve_inverse();
            testCase.verifyFalse(inconsistent.x.exist);
            testCase.verifyEqual(inconsistent.x.contradict(:).', 1);
        end

        function testEquationAndInequalitiesAgainstIndependentOracle(testCase)
            for repetition = 1:testCase.DevelopmentRepetitions
                rng(7100 + repetition, 'twister');
                a = fuzzyMatrix(randi([0 4], 2, 3) / 4);
                witness = fuzzyMatrix(randi([0 4], 3, 1) / 4);
                b = godel(a, witness);

                for inequalities = [-1 0 1]
                    expected = referenceGodelSolutions(a, b, inequalities);
                    actual = fuzzySystem('godel', a, b, [], true, inequalities);

                    context = sprintf(['min-Godel oracle mismatch\n' ...
                        'repetition=%d, inequalities=%d\nA=%s\nB=%s'], ...
                        repetition, inequalities, mat2str(double(a)), ...
                        mat2str(double(b)));
                    verifyNoException(testCase, @() actual.solve_inverse(), context);
                    testCase.verifyEqual(actual.x.exist, expected.exist, context);
                    if expected.exist
                        testCase.verifyEqual(canonical(actual.x.low), ...
                            canonical(expected.low), 'AbsTol', 1e-12, context);
                        if inequalities == -1
                            testCase.verifyTrue(isfield(actual.x, 'gr_inclusive'), ...
                                ['Open Gödel bounds require gr_inclusive.' newline context]);
                            testCase.verifyEqual( ...
                                canonicalBoxes(actual.x.gr, actual.x.gr_inclusive), ...
                                canonicalBoxes(expected.gr, expected.gr_inclusive), ...
                                'AbsTol', 1e-12, context);
                            verifyInteriorPoints(testCase, a, b, actual.x, context);
                        else
                            testCase.verifyEqual(canonical(actual.x.gr), ...
                                canonical(expected.gr), 'AbsTol', 1e-12, context);
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

function result = canonicalBoxes(upper, inclusive)
    combined = [double(upper); double(inclusive)];
    result = sortrows(combined.').';
end

function verifyInteriorPoints(testCase, a, b, solution, context)
    tolerance = 1e-9;
    for k = 1:size(solution.gr, 2)
        interior = double(solution.gr(:, k));
        openCoordinates = ~solution.gr_inclusive(:, k);
        interior(openCoordinates) = max(0, ...
            interior(openCoordinates) - tolerance);
        obtained = double(godel(a, fuzzyMatrix(interior)));
        testCase.verifyLessThanOrEqual(obtained, double(b) + 1e-12, context);
    end
end
