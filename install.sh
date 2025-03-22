#!/bin/bash

# 🟢 Xác định hệ điều hành
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

# 🟢 Cập nhật hệ thống và cài đặt thư viện cần thiết
echo "🟢 Cập nhật hệ thống..."
case $OS in
    "debian")
        sudo apt update && sudo apt upgrade -y
        sudo apt install wget git python3 python3-venv libgl1 libglib2.0-0 -y
        ;;
    "redhat")
        sudo dnf update -y
        sudo dnf install wget git python3 gperftools-libs libglvnd-glx -y
        ;;
    "suse")
        sudo zypper refresh
        sudo zypper install wget git python3 libtcmalloc4 libglvnd -y
        ;;
    "arch")
        sudo pacman -Syu --noconfirm
        sudo pacman -S wget git python3 --noconfirm
        ;;
esac

# 🟢 Kiểm tra GPU NVIDIA và CUDA
echo "🟢 Kiểm tra GPU..."
if command -v nvidia-smi &> /dev/null; then
    CUDA_VERSION=$(nvidia-smi | grep -oP "CUDA Version: \K[\d.]+")
    echo "✅ GPU NVIDIA phát hiện! CUDA đã cài (Version: $CUDA_VERSION)"
else
    echo "❌ Không tìm thấy GPU NVIDIA! Thoát..."
    exit 1
fi

# 🟢 Clone Stable Diffusion WebUI
echo "🟢 Tải Stable Diffusion WebUI..."
if [ ! -d "stable-diffusion-webui" ]; then
    git clone https://github.com/AUTOMATIC1111/stable-diffusion-webui.git
fi
cd stable-diffusion-webui

# 🟢 Cài đặt ControlNet
echo "🟢 Cài đặt ControlNet..."
mkdir -p extensions
if [ ! -d "extensions/sd-webui-controlnet" ]; then
    git clone https://github.com/Mikubill/sd-webui-controlnet.git extensions/sd-webui-controlnet
fi

# 🟢 Tải mô hình ControlNet
echo "🟢 Tải mô hình ControlNet..."
mkdir -p models/ControlNet
cd models/ControlNet
wget -O control_sd15_canny.pth https://huggingface.co/lllyasviel/ControlNet-v1-1/resolve/main/control_v11p_sd15_canny.pth
wget -O control_sd15_depth.pth https://huggingface.co/lllyasviel/ControlNet-v1-1/resolve/main/control_v11f1p_sd15_depth.pth
wget -O control_sd15_linear.pth https://huggingface.co/lllyasviel/ControlNet-v1-1/resolve/main/control_v11p_sd15_lineart.pth
cd ../../

# # 🟢 Cài đặt LoRA
# echo "🟢 Cài đặt LoRA..."
# mkdir -p models/Lora
# cd models/Lora
# wget -O AnythingV3.safetensors https://huggingface.co/Lykon/LykonLoRA/resolve/main/AnythingV3.safetensors
# cd ../../

# 🟢 Tải mô hình Stable Diffusion v1.5
echo "🟢 Tải mô hình SD 1.5..."
mkdir -p models/Stable-diffusion
cd models/Stable-diffusion
wget -O v1-5-pruned-emaonly.safetensors https://huggingface.co/runwayml/stable-diffusion-v1-5/resolve/main/v1-5-pruned-emaonly.safetensors
wget -O realistic-vision-v6.safetensors https://civitai.com/api/download/models/501240
cd ../../

# 🟢 Chạy WebUI với GPU
echo "🟢 Chạy Stable Diffusion WebUI..."
python launch.py --listen --port 7860 --api --disable-safe-unpickle --enable-insecure-extension-access --no-download-sd-model --no-half-vae --xformers --disable-console-progressbars
