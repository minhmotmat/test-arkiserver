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

# 🟢 Định nghĩa thư mục mô hình
MODEL_DIR="models/Stable-diffusion"
CONTROLNET_DIR="extensions/sd-webui-controlnet/models"
LORA_DIR="models/Lora"
TEMP_MODEL_DIR="/tmp/sd-models"

mkdir -p "$MODEL_DIR" "$CONTROLNET_DIR" "$LORA_DIR" "$TEMP_MODEL_DIR"

# 🟢 Tải mô hình Realistic Vision V2.0
REALISTIC_MODEL="$TEMP_MODEL_DIR/Realistic_Vision_V2.0.safetensors"
FINAL_MODEL="$MODEL_DIR/Realistic_Vision_V2.0.safetensors"

if [ -f "$REALISTIC_MODEL" ]; then
    echo "✅ Mô hình Realistic Vision đã có, chỉ copy sang..."
else
    echo "🟢 Tải mô hình Realistic Vision V2.0..."
    wget -O "$REALISTIC_MODEL" "https://huggingface.co/SG161222/Realistic_Vision_V2.0/resolve/main/Realistic_Vision_V2.0.safetensors"
fi
cp "$REALISTIC_MODEL" "$FINAL_MODEL"

# 🟢 Tải mô hình Stable Diffusion v1.5
SD_MODEL="$TEMP_MODEL_DIR/v1-5-pruned-emaonly.safetensors"
FINAL_SD_MODEL="$MODEL_DIR/v1-5-pruned-emaonly.safetensors"

if [ -f "$SD_MODEL" ]; then
    echo "✅ Mô hình SD 1.5 đã có, chỉ copy sang..."
else
    echo "🟢 Tải mô hình SD 1.5..."
    wget -O "$SD_MODEL" "https://huggingface.co/runwayml/stable-diffusion-v1-5/resolve/main/v1-5-pruned-emaonly.safetensors"
fi
cp "$SD_MODEL" "$FINAL_SD_MODEL"

# 🟢 Tải ControlNet Models (nếu chưa có)
CONTROLNET_MODEL="$CONTROLNET_DIR/control_v11p_sd15_canny.pth"
if [ ! -f "$CONTROLNET_MODEL" ]; then
    echo "🟢 Tải ControlNet Model..."
    wget -O "$CONTROLNET_MODEL" "https://huggingface.co/lllyasviel/ControlNet-v1-1/resolve/main/control_v11p_sd15_canny.pth"
else
    echo "✅ ControlNet Model đã có."
fi

# 🟢 Tải LoRA Model (nếu chưa có)
LORA_MODEL="$LORA_DIR/AnythingV3.safetensors"
if [ ! -f "$LORA_MODEL" ]; then
    echo "🟢 Tải LoRA Model..."
    wget -O "$LORA_MODEL" "https://huggingface.co/Lykon/LykonLoRA/resolve/main/AnythingV3.safetensors"
else
    echo "✅ LoRA Model đã có."
fi

# 🟢 Chạy WebUI với GPU
echo "🟢 Chạy Stable Diffusion WebUI..."
python launch.py --xformers --listen --port 7860
