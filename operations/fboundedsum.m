        %Calculate Bounded sum.
        function result = fboundedsum(a,b)
            switch nargin
                case 1
                    a = double(a);
                    if size(a,1) == 1
                        result = a(1);
                        for i = 2:size(a,2)
                            if (result + a(i)) < 1
                                result = result + a(i);
                            else
                                result = 1;
                            end
                        end
                    else
                        result = ones(1,size(a,2));
                        for i = 1:size(a,2)
                            result(i) = fboundedsum(fuzzyMatrix(a(:,i)'));
                        end
                    end
                case 2
                    a = double(a); b = double(b);
                    if ~(all(size(a) == size(b)))
                        error('Matrix dimensions must agree.');
                    end
        
                    result = ones(size(a));
                    result(a + b < 1) = (a(a + b < 1) + b(a + b < 1));
            end
            result = fuzzyMatrix(result);
        end