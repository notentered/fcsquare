        %Calculate Lukasiewicz's tnorm.
        function result = ftnorml(a,b)
            switch nargin
                case 1
                    a = double(a);
                    if size(a,1) == 1
                        result = a(1);
                        for i = 2:size(a,2)
                            if (result + a(i) - 1) > 0
                                result = result + a(i) - 1;
                            else
                                result = 0;
                            end
                        end
                    else
                        result = zeros(1,size(a,2));
                        for i = 1:size(a,2)
                            result(i) = ftnorml(fuzzyMatrix(a(:,i)'));
                        end
                    end
                case 2
                    a = double(a); b = double(b);
                    if ~(all(size(a) == size(b)))
                        error('Matrix dimensions must agree.');
                    end
        
                    result = zeros(size(a));
                    result(a + b - 1 > 0) = (a(a + b - 1 > 0) + b(a + b - 1 > 0) - 1);
            end
            result = fuzzyMatrix(result);
        end