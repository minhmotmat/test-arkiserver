# Stable Diffusion WebUI Setup for vast.ai

This repository contains scripts to automatically set up and run Stable Diffusion WebUI with the Realistic Vision 2.0 model on vast.ai instances.

## Setup Instructions

1. Create a new instance on vast.ai with:

   - CUDA 11.8 or higher
   - At least 12GB VRAM
   - Ubuntu 20.04 or higher

2. Once your instance is running, connect via SSH and run:

```bash
git clone https://github.com/YOUR_REPO/sd-vastai-setup.git
cd sd-vastai-setup
python3 setup_sd_vastai.py
```

3. The script will:

   - Install required dependencies
   - Download and set up Stable Diffusion WebUI
   - Download Realistic Vision 2.0 model
   - Start the WebUI server

4. Access the WebUI:
   - The server will be running on port 7860
   - Use the vast.ai instance IP and port to access: `http://YOUR_INSTANCE_IP:7860`

## Features

- Automatic installation of dependencies
- Downloads Realistic Vision 2.0 model automatically
- Configures WebUI with optimal settings for vast.ai
- Enables API access and xformers optimization

## Troubleshooting

If you encounter any issues:

1. Check the logs in `stable-diffusion-webui/logs` directory
2. Make sure you have enough disk space (at least 20GB recommended)
3. Verify your CUDA installation with `nvidia-smi`
4. Check if port 7860 is accessible through your vast.ai instance settings

## Notes

- The WebUI is configured to listen on all interfaces (0.0.0.0)
- API access is enabled for integration with other tools
- xformers optimization is enabled for better performance
- VAE is set to full precision for better image quality
