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
        
    end
end