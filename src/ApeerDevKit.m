classdef ApeerDevKit < handle
    %ApeerDevKit SDK for creating MATLAB modules on https://www.apeer.com
    %   Reads the inputs from the APEER environment and takes care of correctly
    %   writing back your outputs. Please note that you have to be aware of the
    %   in- and output-keys in your module_specification. These are the keys
    %   used to access the returned input struct as well as the names of the
    %   fields in the output struct.
    
    properties
        args = struct("debug", false, "quiet", false);
        output_params_file = "";
        output_struct = struct();
    end
    
    methods
        function obj = ApeerDevKit(varargin)
            %ApeerDevKit Initializes the apeer dev kit
            %
            %   You can pass --debug or -d to set the ADK into debug mode. It
            %   will then not try to copy files into the APEER directories but
            %   leave all file outputs as is.
            
            obj.parse_arguments(varargin{:});
            
            if ~obj.args.debug
                [status, message] = mkdir("/output");
                if status == 0
                    warning("[ADK] Could not create folder /output: %s", message);
                end
            end
            
            if ~obj.args.quiet; fprintf("[ADK] #### APEER SDK initialized ####\n\n"); end
        end
        
        function inputs_struct = get_inputs(obj)
            %get_inputs Reads all inputs from the APEER environment
            %
            %   Inputs are returned as a struct containing all inputs as fields
            %   with their respective data type as specified in the
            %   module_specification.
            
            if ~obj.args.quiet; fprintf("[ADK] ## Reading inputs ##\n\n"); end
            
            wfe_input_json_key = "WFE_INPUT_JSON";
            input_json = getenv(wfe_input_json_key);
            if isempty(input_json)
                error("adk:WfeInputJsonNotFound", "[ADK] Could not find environment variable ""%s""", wfe_input_json_key);
            end
            if ~obj.args.quiet; fprintf("[ADK] Found environment variable ""%s"":\n\n    %s\n\n", wfe_input_json_key, input_json); end
            
            try
                inputs_struct = jsondecode(input_json);
                if obj.args.debug
                    obj.output_params_file = inputs_struct.WFE_output_params_file;
                else
                    obj.output_params_file = sprintf("/output/%s", inputs_struct.WFE_output_params_file);
                end
                if ~obj.args.quiet; fprintf("[ADK] %s decoded to inputs structure:\n\n", wfe_input_json_key); end
                if ~obj.args.quiet; disp(inputs_struct); end
            catch ex
                error("adk:InvalidWfeInputJson", "[ADK] Could not decode input_json\n\n%s", getReport(ex));
            end
            
            if ~obj.args.quiet; fprintf("[ADK] #### Reading inputs done ####\n\n"); end
        end
        
        function set_output(obj, output_key, output_value)
            %set_output Assigns the given output_value to the given output_key
            
            output_value_text = output_value;
            
            if islogical(output_value)
                output_value_text = "false";
                if output_value
                    output_value_text = "true";
                end
            elseif iscell(output_value)
                output_value_text = "[";
                for i = 1:length(output_value)
                    output_value_text = output_value_text + "" + output_value{i} + """;";
                end
                output_value_text = output_value_text.strip(';') + "]";
            end
            
            if ~obj.args.quiet; fprintf("[ADK] Setting output ""%s"" to ""%s""\n\n", output_key, output_value_text); end
            obj.output_struct.(output_key) = output_value;
        end
        
        function set_file_output(obj, output_key, output_file_path)
            %set_output Copies the output file to the APEER output folder
            
            if ~obj.args.debug
                output_file_path = obj.move_file_to_output_folder(output_file_path);
            end
            obj.set_output(output_key, output_file_path);
        end
        
        function set_multi_file_output(obj, output_key, output_file_paths)
            %set_output Copies the output file to the APEER output folder
            
            if ~obj.args.debug
                for i = 1:length(output_file_paths)
                    output_file_paths{i} = obj.move_file_to_output_folder(output_file_paths{i});
                end
            end
            obj.set_output(output_key, output_file_paths);
        end
        
        function finalize(obj)
            %finalize Writes all assigned outputs
            %
            %   Writes all output values as assigned by set_output and
            %   set_file_output to the output params file as given by the APEER
            %   environment.
            
            if ~obj.args.quiet; fprintf("[ADK] #### Finalizing APEER SDK ####\n\n"); end
            if ~obj.args.quiet; fprintf("[ADK] Encoding output structure:\n\n"); end
            disp(obj.output_struct);
            
            try
                output_json = jsonencode(obj.output_struct);
                if ~obj.args.quiet; fprintf("[ADK] Encoded output structure to json:\n\n    %s\n\n", output_json); end
            catch ex
                error("[ADK] Could not encode output structure\n\n%s", getReport(ex));
            end
            
            if ~obj.args.quiet; fprintf("[ADK] Writing encoded outputs to ""%s""\n\n", obj.output_params_file); end
            
            [fileId, message] = fopen(obj.output_params_file, "w");
            if fileId == -1
                error("[ADK] Could not open file ""%s"": %s", obj.output_params_file, message);
            end
            
            if ~obj.args.quiet; fprintf(fileId, output_json); end
            
            if fclose(fileId)
                error("[ADK] Could not write to file ""%s""", obj.output_params_file);
            end
            
            if ~obj.args.debug
                if ~obj.args.quiet; fprintf("[ADK] Content of ""/output"":\n\n    "); end
                if ~obj.args.quiet; disp(ls("/output")); end
            end
            
            if ~obj.args.quiet; fprintf("[ADK] #### APEER SDK finalized ####\n\n"); end
        end
    end
    
    methods (Access = private)
        function parse_arguments(obj, varargin)
            for i = 1:numel(varargin)
                if strcmp(varargin{i}, "--debug") || strcmp(varargin{i}, "-d")
                    obj.args.debug = true;
                elseif strcmp(varargin{i}, "--quiet") || strcmp(varargin{i}, "-q")
                    obj.args.quiet = true;
                end
            end
            
            if obj.args.debug
                if ~obj.args.quiet; warning("APEER SDK running in debug mode."); end
            end
        end
        
        function output_file_path = move_file_to_output_folder(obj, output_file_path)
            [path, filename, ext] = fileparts(output_file_path);
            if ~startsWith(path, "/output/")
                destination = sprintf("/output/%s%s", filename, ext);
                if ~obj.args.quiet; fprintf("[ADK] Moving ""%s"" to ""%s""\n\n", output_file_path, destination); end
                [status, message] = movefile(output_file_path, destination);
                if status == 0
                    error("[ADK] Could not move ""%s"" to ""%s"": %s", output_file_path, destination, message);
                end
                output_file_path = destination;
            end
        end
    end
end

