classdef ApeerDevKitTests < matlab.unittest.TestCase
  
    methods (Test)
        
        function adk_initialize_setsDebugMode_withShortArgument(testCase)      
            adk = ApeerDevKit("-d");
            testCase.assertEqual(adk.args.debug, true);
        end
        
        function adk_initialize_setsDebugMode_withLongArgument(testCase)      
            adk = ApeerDevKit("--debug");
            testCase.assertEqual(adk.args.debug, true);
        end
        
    end
end