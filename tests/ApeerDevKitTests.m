classdef ApeerDevKitTests < matlab.unittest.TestCase
    
    methods (Test)
        
        %% initialize
        
        function adk_initialize_debugModeIsFalseByDefault(testCase)
            adk = ApeerDevKit;
            testCase.assertEqual(adk.args.debug, false);
        end
        
        function adk_initialize_debugModeIsTrueWhenDArgumentIsGiven(testCase)
            adk = ApeerDevKit("-d");
            testCase.assertEqual(adk.args.debug, true);
        end
        
        function adk_initialize_debugModeIsTrueWhenDebugArgumentIsGiven(testCase)
            adk = ApeerDevKit("--debug");
            testCase.assertEqual(adk.args.debug, true);
        end
        
        %% get_inputs
        
        function adk_get_inputs_throwsErrorWhenWfeInputJsonNotFound(testCase)
            adk = ApeerDevKit("-d");
            setenv("WFE_INPUT_JSON", "");
            
            testCase.assertError(@()adk.get_inputs(), "adk:WfeInputJsonNotFound");
        end
        
        function adk_get_inputs_throwsErrorWhenWfeInputJsonInWrongFormat(testCase)
            adk = ApeerDevKit("-d");
            setenv("WFE_INPUT_JSON", "{{");
            
            testCase.assertError(@()adk.get_inputs(), "adk:InvalidWfeInputJson");
        end
        
        function adk_get_inputs_throwsErrorWhenWfeInputJsonMissesParamsFile(testCase)
            adk = ApeerDevKit("-d");
            setenv("WFE_INPUT_JSON", "{}");
            
            testCase.assertError(@()adk.get_inputs(), "adk:InvalidWfeInputJson");
        end
        
        function adk_get_inputs_parsesWfeInputJsonWithCorrectDataTypes(testCase)
            adk = ApeerDevKit("-d");
            setenv("WFE_INPUT_JSON", "{""WFE_output_params_file"":""out.json"",""aChar"":""ichbineintext"",""aNumber"":42, ""anArray"":[""value1"",""value2""], ""aBoolean"":true}");
            
            inputs_struct = adk.get_inputs();
            
            testCase.assertInstanceOf(inputs_struct, "struct");
            testCase.assertInstanceOf(inputs_struct.WFE_output_params_file, "char");
            testCase.assertInstanceOf(inputs_struct.aChar, "char");
            testCase.assertInstanceOf(inputs_struct.aNumber, "double");
            testCase.assertInstanceOf(inputs_struct.anArray, "cell");
            testCase.assertInstanceOf(inputs_struct.aBoolean, "logical");
        end
        
        function adk_get_inputs_parsesWfeInputJsonWithCorrectValues(testCase)
            adk = ApeerDevKit("-d");
            setenv("WFE_INPUT_JSON", "{""WFE_output_params_file"":""out.json"",""aChar"":""ichbineintext"",""aNumber"":42, ""anArray"":[""value1"",""value2""], ""aBoolean"":true}");
            
            inputs_struct = adk.get_inputs();
            
            testCase.assertEqual(inputs_struct.WFE_output_params_file, 'out.json');
            testCase.assertEqual(inputs_struct.aChar, 'ichbineintext');
            testCase.assertEqual(inputs_struct.aNumber, 42, "AbsTol", eps);
            testCase.assertEqual(inputs_struct.anArray{1}, 'value1');
            testCase.assertEqual(inputs_struct.anArray{2}, 'value2');
            testCase.assertEqual(inputs_struct.aBoolean, true);
        end
        
        %% set_output
        
        function adk_set_output_addsOutputToOutputStructWithCorrectDataType(testCase)
            adk = ApeerDevKit("-d");
            
            adk.set_output("aString", "ichbineintext");
            adk.set_output("aNumber", 47.11);
            adk.set_output("aBoolean", true);
            adk.set_output("anArray", {"value1", "value2"});
            
            testCase.assertInstanceOf(adk.output_struct.aString, "string");
            testCase.assertInstanceOf(adk.output_struct.aNumber, "double");
            testCase.assertInstanceOf(adk.output_struct.aBoolean, "logical");
            testCase.assertInstanceOf(adk.output_struct.anArray, "cell");
        end
        
        function adk_set_output_addsOutputToOutputStructWithCorrectValue(testCase)
            adk = ApeerDevKit("-d");
            
            adk.set_output("aString", "ichbineintext");
            adk.set_output("aNumber", 47.11);
            adk.set_output("aBoolean", true);
            adk.set_output("anArray", {"value1", "value2"});
            
            testCase.assertEqual(adk.output_struct.aString, "ichbineintext");
            testCase.assertEqual(adk.output_struct.aNumber, 47.11, "AbsTol", eps);
            testCase.assertEqual(adk.output_struct.aBoolean, true);
            testCase.assertEqual(adk.output_struct.anArray{1}, "value1");
            testCase.assertEqual(adk.output_struct.anArray{2}, "value2");
        end
        
        %% set_file_output
        
        % [WIP]
        
        %% finalize
        
        % [WIP]
        
    end
end
