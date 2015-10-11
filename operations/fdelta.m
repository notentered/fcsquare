        %Calculate delta operation.
        function result = fdelta(a,b)
            switch nargin
                case 1
                    a = double(a);
                    if size(a,1) == 1
                        result = a(1);
                        for i = 2:size(a,2)
                            if (a(i) - result) > 0
                                result = a(i) - result;
                            else
                                result = 0;
                            end
                        end
                    else
                        result = zeros(1,size(a,2));
                        for i = 1:size(a,2)
                            result(i) = fdelta(fuzzyMatrix(a(:,i)'));
                        end
                    end
                case 2
                    a = double(a); b = double(b);
                    if ~(all(size(a) == size(b)))
                        error('Matrix dimensions must agree.');
                    end
        
                    result = zeros(size(a));
                    result(b - a > 0) = (b(b - a > 0) - a(b - a > 0)); 
            end
            result = fuzzyMatrix(result);
        end