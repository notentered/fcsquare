function verifyNoException(testCase, fcnHandle, diagnosticMessage)
%VERIFYNOEXCEPTION Helper for tests: verify that calling fcnHandle()
% does NOT throw an exception. If it does, fail the test and print the
% diagnostic message plus the exception report.
%
% Usage:
%   verifyNoException(testCase, @() obj.method(), 'Some context...');

    if nargin < 3
        diagnosticMessage = '';
    end

    try
        fcnHandle();
    catch ME
        fullMessage = sprintf('%s\nUnexpected exception: %s\n%s', ...
            diagnosticMessage, ME.identifier, ...
            getReport(ME, 'extended', 'hyperlinks', 'off'));
        testCase.verifyFail(fullMessage);
    end
end
