#!/bin/bash

# 🟢 Kiểm tra hệ điều hành
echo "🟢 Kiểm tra hệ điều hành..."
if [ -f /etc/debian_version ]; then
    OS="debian"
elif [ -f /etc/redhat-release ]; then
    OS="redhat"
elif [ -f /etc/SuSE-release ]; then
    OS="suse"
elif [ -f /etc/arch-release ]; then
    OS="arch"
else
    echo "❌ Hệ điều hành không được hỗ trợ!"
    exit 1
fi

# 🟢 Kiểm tra CUDA đã cài đặt chưa
if command -v nvcc &> /dev/null; then
    CUDA_VERSION=$(nvcc --version | grep "release" | awk '{print $6}' | tr -d ",")
    echo "✅ CUDA is installed (version: $CUDA_VERSION)"
else
    echo "❌ CUDA chưa được cài đặt. Tiến hành cài đặt..."
    
    case $OS in
        "debian") 
            sudo apt update && sudo apt install -y nvidia-driver-535 nvidia-cuda-toolkit
            ;;
        "redhat") 
            sudo dnf install -y xorg-x11-drv-nvidia-cuda
            ;;
        "suse") 
            sudo zypper install -y x11-video-nvidiaG05
            ;;
        "arch") 
            sudo pacman -S --noconfirm nvidia nvidia-utils cuda
            ;;
    esac
fi

# 🟢 Kiểm tra nếu đang chạy trên Vast.ai
if [ -f "/.dockerenv" ] && docker images | grep -q "vastai/base-image"; then
    echo "✅ Đang chạy trên Vast.ai, CUDA & cuDNN đã được cài sẵn."
fi

# 🟢 Clone Stable Diffusion WebUI
echo "🟢 Tải Stable Diffusion WebUI..."
git clone https://github.com/AUTOMATIC1111/stable-diffusion-webui.git
cd stable-diffusion-webui

# 🟢 Tải mô hình Stable Diffusion v1.5 (Realistic Vision V2.0)
echo "🟢 Tải mô hình Stable Diffusion Realistic Vision V2.0..."
mkdir -p models/Stable-diffusion
wget -O models/Stable-diffusion/model.safetensors https://huggingface.co/SG161222/Realistic_Vision_V2.0/resolve/main/Realistic_Vision_V2.0.safetensors

# 🟢 Cài đặt ControlNet
echo "🟢 Cài đặt ControlNet..."
mkdir -p extensions
git clone https://github.com/Mikubill/sd-webui-controlnet.git extensions/sd-webui-controlnet

# 🟢 Tải mô hình ControlNet
echo "🟢 Tải mô hình ControlNet..."
mkdir -p models/ControlNet
cd models/ControlNet
wget -O control_sd15_openpose.pth https://huggingface.co/lllyasviel/ControlNet-v1-1/resolve/main/control_sd15_openpose.pth
wget -O control_sd15_canny.pth https://huggingface.co/lllyasviel/ControlNet-v1-1/resolve/main/control_sd15_canny.pth
wget -O control_sd15_depth.pth https://huggingface.co/lllyasviel/ControlNet-v1-1/resolve/main/control_sd15_depth.pth
cd ../../

# 🟢 Cài đặt LoRA
echo "🟢 Cài đặt LoRA..."
mkdir -p models/Lora
git clone https://github.com/kohya-ss/sd-scripts.git extensions/sd-scripts

# 🟢 Tải một số mô hình LoRA mẫu
echo "🟢 Tải mô hình LoRA..."
wget -O models/Lora/chilloutmix-lora.safetensors https://civitai.com/api/download/models/6274
wget -O models/Lora/toonify.safetensors https://civitai.com/api/download/models/7893

# 🟢 Chạy WebUI với GPU
echo "🟢 Chạy Stable Diffusion WebUI..."
python launch.py --xformers --listen --port 7860
