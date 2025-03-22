import os
import subprocess
import sys
from pathlib import Path

def run_cmd(cmd):
    process = subprocess.Popen(cmd, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    stdout, stderr = process.communicate()
    print(stdout.decode('utf-8'))
    if stderr:
        print("Error:", stderr.decode('utf-8'))
    return process.returncode

def setup_environment():
    print("Setting up environment...")
    
    # Install PyTorch with CUDA support
    print("Installing PyTorch with CUDA support...")
    run_cmd("pip3 install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu118")
    
    # Install other Python dependencies from requirements.txt
    print("Installing other Python dependencies...")
    run_cmd("pip3 install -r requirements.txt")
    
    # Clone A1111 WebUI
    if not os.path.exists("stable-diffusion-webui"):
        print("Cloning Stable Diffusion WebUI...")
        run_cmd("git clone https://github.com/AUTOMATIC1111/stable-diffusion-webui.git")
    
    # Create models directory
    os.makedirs("stable-diffusion-webui/models/Stable-diffusion", exist_ok=True)

def download_model():
    print("Downloading Realistic Vision 2.0 model...")
    model_url = "https://huggingface.co/SG161222/Realistic_Vision_V2.0/resolve/main/Realistic_Vision_V2.0.safetensors"
    model_path = "stable-diffusion-webui/models/Stable-diffusion/Realistic_Vision_V2.0.safetensors"
    
    if not os.path.exists(model_path):
        run_cmd(f"wget -O {model_path} {model_url}")
        print("Model downloaded successfully!")
    else:
        print("Model already exists, skipping download.")

def setup_webui():
    print("Setting up WebUI...")
    os.chdir("stable-diffusion-webui")
    
    # Create webui-user.sh with custom settings
    with open("webui-user.sh", "w") as f:
        f.write("""#!/bin/bash
export COMMANDLINE_ARGS="--listen --port 7860 --api --xformers --enable-insecure-extension-access --no-half-vae"
""")
    
    # Make it executable
    run_cmd("chmod +x webui-user.sh")

def main():
    try:
        setup_environment()
        download_model()
        setup_webui()
        
        print("\nStarting WebUI...")
        print("The WebUI will be available at http://YOUR_INSTANCE_IP:7860")
        os.chdir("stable-diffusion-webui")
        run_cmd("./webui.sh")
    except Exception as e:
        print(f"Error occurred: {str(e)}")
        sys.exit(1)

if __name__ == "__main__":
    main() 