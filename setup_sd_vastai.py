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

def check_cuda():
    try:
        import torch
        if torch.cuda.is_available():
            print(f"CUDA is available. PyTorch version: {torch.__version__}")
            print(f"CUDA version: {torch.version.cuda}")
            return True
    except ImportError:
        pass
    return False

def setup_environment():
    print("Setting up environment...")
    
    # Check if CUDA and PyTorch are already installed
    if not check_cuda():
        print("Installing PyTorch with CUDA support...")
        run_cmd("pip3 install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu118")
    else:
        print("PyTorch with CUDA support is already installed, skipping...")
    
    # Install other Python dependencies from requirements.txt
    print("Installing other Python dependencies...")
    run_cmd("pip3 install -r requirements.txt")
    
    # Get current directory
    current_dir = os.getcwd()
    print(f"Current directory: {current_dir}")
    
    # Clone A1111 WebUI
    webui_dir = os.path.join(current_dir, "stable-diffusion-webui")
    if not os.path.exists(webui_dir):
        print("Cloning Stable Diffusion WebUI...")
        result = run_cmd("git clone https://github.com/AUTOMATIC1111/stable-diffusion-webui.git")
        if result != 0:
            raise Exception("Failed to clone WebUI repository")
    else:
        print("WebUI directory already exists, updating...")
        os.chdir(webui_dir)
        run_cmd("git pull")
        os.chdir(current_dir)
    
    # Create models directory
    models_dir = os.path.join(webui_dir, "models", "Stable-diffusion")
    os.makedirs(models_dir, exist_ok=True)
    return webui_dir

def download_model(webui_dir):
    print("Downloading Realistic Vision 2.0 model...")
    model_url = "https://huggingface.co/SG161222/Realistic_Vision_V2.0/resolve/main/Realistic_Vision_V2.0.safetensors"
    model_path = os.path.join(webui_dir, "models", "Stable-diffusion", "Realistic_Vision_V2.0.safetensors")
    
    if not os.path.exists(model_path):
        result = run_cmd(f"wget -O {model_path} {model_url}")
        if result != 0:
            raise Exception("Failed to download model")
        print("Model downloaded successfully!")
    else:
        print("Model already exists, skipping download.")

def setup_webui(webui_dir):
    print("Setting up WebUI...")
    if not os.path.exists(webui_dir):
        raise Exception(f"WebUI directory not found: {webui_dir}")
    
    os.chdir(webui_dir)
    print(f"Changed directory to: {os.getcwd()}")
    
    # Create webui-user.sh with custom settings
    with open("webui-user.sh", "w") as f:
        f.write("""#!/bin/bash
export COMMANDLINE_ARGS="--listen --port 7860 --api --xformers --enable-insecure-extension-access --no-half-vae"
""")
    
    # Make it executable
    run_cmd("chmod +x webui-user.sh")

def main():
    try:
        # Setup environment and get WebUI directory
        webui_dir = setup_environment()
        
        # Download model
        download_model(webui_dir)
        
        # Setup and start WebUI
        setup_webui(webui_dir)
        
        print("\nStarting WebUI...")
        print(f"Current directory: {os.getcwd()}")
        print(f"WebUI directory: {webui_dir}")
        print("The WebUI will be available at http://localhost:7860")
        
        if not os.path.exists("webui.sh"):
            raise Exception("webui.sh not found in current directory")
            
        result = run_cmd("./webui.sh")
        if result != 0:
            raise Exception("Failed to start WebUI")
            
    except Exception as e:
        print(f"Error occurred: {str(e)}")
        print(f"Current directory: {os.getcwd()}")
        print("Stack trace:", sys.exc_info())
        sys.exit(1)

if __name__ == "__main__":
    main() 