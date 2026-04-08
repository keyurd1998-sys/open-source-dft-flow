#!/bin/bash

# Exit on any error
set -e

# --- NEW: FORCE HOME DIRECTORY ---
# This ensures that no matter where you run the script from, 
# the files go to /home/youruser/
cd "$HOME"

clear

echo "=========================================================="
echo "        FAULT-DFT AUTOMATED INSTALLATION SCRIPT"
echo "=========================================================="

# CRITICAL RESOURCE WARNING
echo "‼️  IMPORTANT: SYSTEM RESOURCE WARNING ‼️"
echo "This script will use ALL available CPU cores ($(nproc))."
echo "To prevent your VirtualBox from freezing:"
echo "----------------------------------------------------------"
echo "1. CLOSE all other applications (Browsers, IDEs, Music)."
echo "2. DO NOT run other processes in parallel."
echo "3. Ensure your laptop is plugged into power."
echo "----------------------------------------------------------"
echo ""

# Proceed or Abort Option
read -p "Are you ready to continue in $HOME? (y/n): " confirm
if [[ $confirm != [yY] ]]; then
    echo "Installation cancelled by user."
    exit 1
fi

echo -e "\n Starting installation... Please be patient!"
echo "=========================================================="
sleep 2

# 0. Initial Environment Check
if [ -f "$HOME/.cargo/env" ]; then
    source "$HOME/.cargo/env"
fi

# 1. Update and Install System Dependencies
echo -e "\n[1/6]  Installing System Dependencies..."
sudo apt-get update -qq
sudo apt-get install -y gawk git make python3 python3-pip python3-venv \
    build-essential lld bison clang flex libffi-dev libfl-dev \
    libreadline-dev pkg-config tcl-dev zlib1g-dev graphviz xdot \
    autoconf gperf g++ libssl-dev curl -y

# 2. Setup Python Virtual Environment
echo -e "\n[2/6]  Setting up Python Virtual Environment..."
# Created specifically in ~/fault_env
python3 -m venv "$HOME/fault_env"
source "$HOME/fault_env/bin/activate"
pip install --upgrade pip -q
pip install fault-dft -q
echo "✅ Fault-DFT Python Library Installed."

# 3. Install Icarus Verilog from Source
echo -e "\n[3/6]  Building Icarus Verilog from Source..."
echo "⏳ This usually takes 5-10 minutes. Compiling now..."
if [ ! -d "$HOME/iverilog" ]; then
    git clone https://github.com/steveicarus/iverilog.git -q "$HOME/iverilog"
fi
cd "$HOME/iverilog"
sh autoconf.sh > /dev/null
./configure > /dev/null
make -j$(nproc) > /dev/null
sudo make install > /dev/null
echo "✅ Icarus Verilog Installed."

# 4. Install Rust and Quaigh
echo -e "\n[4/6]  Installing Rust and Quaigh..."
if ! command -v cargo &> /dev/null; then
    echo "⏳ Rust not found. Installing now..."
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y -q
    source "$HOME/.cargo/env"
fi
echo "⏳ Building Quaigh (Rust build)..."
cargo install quaigh -q
echo "✅ Quaigh Installed."

# 5. Install Yosys from Source
echo -e "\n[5/6] 💎 Building Yosys from Source..."
echo "----------------------------------------------------------"
echo "🕒 THIS IS THE LONGEST STEP (Approx 60 MINUTES)."
echo "🚀 Using all $(nproc) cores. Do not start other tasks!"
echo "----------------------------------------------------------"

if [ ! -d "$HOME/yosys" ]; then
    git clone --recurse-submodules https://github.com/YosysHQ/yosys.git -q "$HOME/yosys"
fi
cd "$HOME/yosys"
make config-clang > /dev/null
echo "  Compiling Yosys kernel and submodules..."
make -j$(nproc) > /dev/null
sudo make install > /dev/null
echo "✅ Yosys Installed."

# 6. Cleanup Phase (Optional but Recommended)
echo -e "\n[6/6] 🧹 Cleanup Phase"
read -p "Delete the source build folders in ~ to save 2GB space? (y/n): " cleanup_confirm
if [[ $cleanup_confirm == [yY] ]]; then
    rm -rf "$HOME/iverilog"
    rm -rf "$HOME/yosys"
    sudo apt-get autoremove -y > /dev/null
    echo "✅ Cleaned up source folders."
fi

# Final Verification
echo -e "\n=========================================================="
echo " ALL SYSTEMS GO! Verification Summary:"
echo "=========================================================="
echo "📍 Yosys:         $(yosys -V)"
echo "📍 Icarus:        $(iverilog -V | head -n 1)"
echo "📍 Quaigh:        Installed"
source "$HOME/fault_env/bin/activate"
echo "📍 Fault-DFT:     $(python3 -c "import fault; print('Ready')")"
echo "=========================================================="
echo " To work, run: source ~/fault_env/bin/activate && source ~/.cargo/env"
echo "=========================================================="
