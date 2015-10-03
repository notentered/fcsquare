        %Calculate gama operation; reziduum of probalistic sum
        function result = fgama(a,b)
            switch nargin
                case 1
                    a = double(a);
                    if size(a,1) == 1
                        result = 0;
                        for i = 1:size(a,2)
                            if result < a(i)
                                result = (a(i)-result)/(1-result);
                            else
                                result = 0;
                            end
                        end
                    else
                        result = zeros(1,size(a,2));
                        for i = 1:size(a,2)
                            result(i) = fgama(fuzzyMatrix(a(:,i)'));
                        end
                       
                    end
                case 2
                    a = double(a); b = double(b);
                    if ~(all(size(a) == size(b)))
                        error('Matrix dimensions must agree.');
                    end
        
                    result = zeros(size(a));
                    result(b>a) = (b(b>a)-a(b>a))./(1-a(b>a));
            end
            result = fuzzyMatrix(result);
        end