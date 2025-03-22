#!/bin/bash

echo "Checking system requirements..."

# Check Python 3.11
if command -v python3.11 &> /dev/null; then
    echo "Python 3.11 is already installed"
    PYTHON_INSTALLED=true
else
    echo "Python 3.11 is not installed"
    PYTHON_INSTALLED=false
fi

# Check CUDA
if command -v nvidia-smi &> /dev/null; then
    CUDA_VERSION=$(nvidia-smi --query-gpu=cuda_version --format=csv,noheader)
    echo "CUDA is installed (version: $CUDA_VERSION)"
    CUDA_INSTALLED=true
else
    echo "CUDA is not installed"
    CUDA_INSTALLED=false
fi

# If both are installed, skip installation
if [ "$PYTHON_INSTALLED" = true ] && [ "$CUDA_INSTALLED" = true ]; then
    echo "All requirements are met. Running setup script..."
    python3.11 setup_sd_vastai.py
    exit 0
fi

echo "Installing missing dependencies..."

# Detect distribution
if [ -f "/etc/debian_version" ]; then
    echo "Debian-based system detected"
    apt-get update
    apt-get install -y wget git python3 python3-venv libgl1 libglib2.0-0
    
    # Install Python 3.11 if not installed
    if [ "$PYTHON_INSTALLED" = false ]; then
        add-apt-repository -y ppa:deadsnakes/ppa
        apt-get update
        apt-get install -y python3.11 python3.11-venv
    fi
elif [ -f "/etc/redhat-release" ]; then
    echo "Red Hat-based system detected"
    dnf install -y wget git python3 gperftools-libs libglvnd-glx
elif [ -f "/etc/arch-release" ]; then
    echo "Arch-based system detected"
    pacman -Sy --noconfirm wget git python3
elif [ -f "/etc/opensuse-release" ]; then
    echo "openSUSE-based system detected"
    zypper install -y wget git python3 libtcmalloc4 libglvnd
else
    echo "Defaulting to Debian-based installation"
    apt-get update
    apt-get install -y wget git python3 python3-venv libgl1 libglib2.0-0
    if [ "$PYTHON_INSTALLED" = false ]; then
        add-apt-repository -y ppa:deadsnakes/ppa
        apt-get update
        apt-get install -y python3.11 python3.11-venv
    fi
fi

echo "Initial setup complete. Running Python setup script..."
python3.11 setup_sd_vastai.py 