classdef test_prueba < matlab.unittest.TestCase
   
    
    methods (Test)
        function prueba(testCase)
            x = rand(10000,1);
            testCase.verifyEqual(x,x);
        end
        
    end
end