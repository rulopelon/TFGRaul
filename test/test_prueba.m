classdef test_prueba < matlab.unittest.TestCase

    methods (Test)
        function pruebaInterpolacion(testCase)
            L = [1,2,3,4,10];
            x = rand(10000,1);
            for i = L
                inter = interpolacion(x,i);
                upsam = upsample(x,i);
                testCase.verifyEqual(inter,upsam);
            end
            
        end
        function pruebaGetfilter(testCase)
            L = [10,12,14,16,18,20];
            L = 2.^L;
            for i = L 
                x = getFilter(2,3,i);
                testCase.verifyEqual(i,length(x));
            end
        end
        
    end
end