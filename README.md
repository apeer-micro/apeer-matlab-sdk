# APEER Matlab SDK

[![Build Status](https://travis-ci.com/apeer-micro/apeer-matlab-sdk.svg?branch=master)](https://travis-ci.com/apeer-micro/apeer-matlab-sdk)
[![License](https://img.shields.io/badge/Code%20License-MIT-blue.svg)](https://github.com/apeer-micro/apeer-matlab-sdk/blob/master/LICENSE)

## What it does

Our APEER Matlab SDK aka. **A**peer**D**ev**K**it (ADK) is a Matlab class library for reading inputs and writing outputs of [APEER](https://www.apeer.com) modules. The ADK will take care of reading inputs from previous modules in APEER and writing your outputs in the correct format for the next module.

## Installation

Just clone this repository and reference `ApeerDevKit.m` during you matlab compilation.

`mcc -mv /path/to/your-script.m -I /path/to/adk-folder -d /path/to/bin-folder`

## How to Use

```matlab
%%%% apeer_main.m %%%%

function [] = apeer_main(varargin)
    adk = ApeerDevKit(varargin{:});
    inputs = adk.get_inputs();

    outputs = your_script(inputs.input_image);
    
    adk.set_output("success", outputs.success);
    adk.set_file_output("equalized_image", outputs.equalized_image);
    adk.finalize();
end

%%%% your_script.m %%%%

function [outputs] = your_script(input_image_path)

    % your processing code goes here ...

    % Make sure you return the outputs as a structure containing all output
    % values as specified for your APEER module as fields
    outputs.success = true;
    outputs.equalized_image = equalized_image_path;
end
```

## API

### Reading inputs

* `get_inputs()`: This methods returns a structure containing your inputs. The keys in the dictionary are defined in your [module_specification](http://cadevelop.blob.core.windows.net/public/adk_github_wiki/inputs_spec.png).

### Writing putputs

After your done with processing in your code. You want to pass your output to the next module. In order to pass a file output use `set_file_output()` and to pass every output type except `file` type, use `set_output()`. 

* `set_output`(): This method allows you to pass non-file output to the next module. Example: `adk.set_output("success", true)`. The first argument is the key, which you find in the [module_specification](http://cadevelop.blob.core.windows.net/public/adk_github_wiki/inputs_spec.png). The second argument is the value that you have calculated.

* `set_file_output()`: This method allows your to pass your file output to next module. 
Example: `adk.set_file_output("equalized_image", "/path/to/image.png")`. The first argument is the key, which you will find in your [module_specification](http://cadevelop.blob.core.windows.net/public/adk_github_wiki/inputs_spec.png). he second argument is the filepath to your file.
