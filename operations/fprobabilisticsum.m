        %Calculate Probabulistic sum.
        function result = fprobabilisticsum(a,b)
            switch nargin
                case 1
                    a = double(a);
                    if size(a,1) == 1
                        result = a(1);
                        for i = 2:size(a,2)
   
                                result = result + a(i) - result*a(i);
                           
                        end
                    
                    else
                        result = ones(1,size(a,2));
                       for i = 1:size(a,2)
                            result(i) = fprobabilisticsum(fuzzyMatrix(a(:,i)'));
                        end
                    end
                case 2
                    a = double(a); b = double(b);
                    if ~(all(size(a) == size(b)))
                        error('Matrix dimensions must agree.');
                    end
        
                   
                    result = (a + b -a.*b);
            end
            result = fuzzyMatrix(result);
        end