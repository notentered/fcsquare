        %Calculate alpha operation.
        function result = falpha(a,b)
            switch nargin
                case 1
                    a = double(a);
                    if size(a,1) == 1
                        result = 1;
                        for i = 1:size(a,1)
                            if result > a(i)
                                result = a(i);
                            else
                                result = 1;
                            end
                        end
                    else
                        result = ones(1,size(a,2));
                        for i = 1:size(a,2)
                            result(i) = falpha(fuzzyMatrix(a(:,i)'));
                        end
                    end
                case 2
                    a = double(a); b = double(b);
                    if ~(all(size(a) == size(b)))
                        error('Matrix dimensions must agree.');
                    end
        
                    result = ones(size(a));
                    result(a>b) = b(a>b);
            end
            result = fuzzyMatrix(result);
        end