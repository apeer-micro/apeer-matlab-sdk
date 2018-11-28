classdef ApeerDevKit < handle
    %ApeerDevKit SDK for creating MATLAB modules on https://www.apeer.com
    %   Reads the inputs from the APEER environment and takes care of correctly
    %   writing back your outputs. Please note that you have to be aware of the
    %   in- and output-keys in your module_specification. These are the keys
    %   used to access the returned input struct as well as the names of the
    %   fields in the output struct.
    
    properties
        output_params_file
        output_struct = struct();
    end
    
    methods
        function obj = ApeerDevKit()
            %ApeerDevKit Initializes the apeer dev kit
        end
        
        function inputs_struct = get_inputs(obj)
            %METHOD1 Reads all inputs from the APEER environment
            %   Inputs are returned as a struct containing all inputs as fields
            %   with their respective data type as specified in the
            %   module_specification.
            
            fprintf('Reading inputs...\n');
            
            input_json = getenv('WFE_INPUT_JSON');
            if isempty(input_json)
                error('Could not find environment variable WFE_INPUT_JSON.');
            end
            
            fprintf('Found environment variable WFE_INPUT_JSON: %s\n', input_json);
            
            try
                inputs_struct = jsondecode(input_json);
                obj.output_params_file = inputs_struct.WFE_output_params_file;
                fprintf('Decoded WFE_INPUT_JSON to\n');
                disp(inputs_struct);
            catch ex
                error('Could not decode input_json: %s\n', getReport(ex));
            end
        end
        
        function set_output(obj, output_key, output_value)
            error('Function not yet implemented');
        end
        
        function set_file_output(obj, output_key, output_file_path)
            error('Function not yet implemented');
        end
        
        function finalize(obj)
            
            fprintf('Writing output_struct...\n');
            disp(obj.output_struct);
            
            try
                output_json = jsonencode(obj.output_struct);
                fprintf('Encoded output_json: %s\n', output_json);
            catch ex
                error('Could not encode output_struct: %s\n', getReport(ex));
            end
            
            output_json_file = fopen(obj.output_params_file, 'w');
            fprintf(output_json_file, output_json);
            fclose(output_json_file);
        end
    end
end

