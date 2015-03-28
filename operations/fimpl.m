        %Calculate Lukasiewicz's implication.
        function result = fimpl(a,b)
            switch nargin
                case 1
                    a = double(a);
                    if size(a,1) == 1
                        result = a(1);
                        for i = 2:size(a,2)
                            if (1 - result + a(i)) < 1
                                result = 1 - result + a(i);
                            else
                                result = 1;
                            end
                        end
                    else
                        result = ones(1,size(a,2));
                        for i = 1:size(a,2)
                            result(i) = fimpl(fuzzyMatrix(a(:,i)'));
                        end
                    end
                case 2
                    a = double(a); b = double(b);
                    if ~(all(size(a) == size(b)))
                        error('Matrix dimensions must agree.');
                    end
        
                    result = ones(size(a));
                    result(1 - a + b < 1) = (1 - a(1 - a + b < 1) + b(1 - a + b < 1));
            end
            result = fuzzyMatrix(result);
        end