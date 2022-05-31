# Import pyxir before onnxruntime
import pyxir
import pyxir.frontend.onnx

import onnxruntime
import sys


# Add other imports 
# ...

# Load inputs and do preprocessing
# ...


# Create an inference session using the Vitis-AI execution provider

def execute_with_fpga(model_name):
    target='DPUCADX8G'
    vitis_ai_provider_options = {'target': target, 'export_runtime_module': 'vitis_ai_dpu.rtmod'}
    session = onnxruntime.InferenceSession(model_name, None, ["VitisAIExecutionProvider"], [vitis_ai_provider_options])

def execute_with_cpu(model_name):
    session = onnxruntime.InferenceSession(model_name, providers=["CPUExecutionProvider"])


if len(sys.argv) > 2:
    execute_with_fpga(sys.argv[1])
else:
    execute_with_cpu(sys.argv[1])
