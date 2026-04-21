#!/bin/bash

# Exit on any error
set -e

# FORCE HOME DIRECTORY
cd "$HOME"
clear

echo "=========================================================="
echo "        FAULT-DFT AUTOMATED INSTALLATION SCRIPT"
echo "=========================================================="
echo "‼️  IMPORTANT: SYSTEM RESOURCE WARNING ‼️"
echo "This script will use ALL available CPU cores ($(nproc))."
echo "To prevent your VirtualBox from freezing:"
echo "----------------------------------------------------------"
echo "1. CLOSE all other applications (Browsers, IDEs, Music)."
echo "2. DO NOT run other processes in parallel."
echo "3. Ensure your laptop is plugged into power."
echo "----------------------------------------------------------"
echo ""
# Proceed or Abort
read -p "Are you ready to continue in $HOME? (y/n): " confirm
if [[ $confirm != [yY] ]]; then
    echo "Installation cancelled by user."
    exit 1
fi

# System Dependencies
echo -e "\n[1/7] Installing System Dependencies..."
sudo apt-get update -qq
sudo apt-get install -y gawk git make python3 python3-pip python3-venv \
    build-essential lld bison clang flex libffi-dev libfl-dev \
    libreadline-dev pkg-config tcl-dev zlib1g-dev graphviz xdot \
    autoconf gperf g++ libssl-dev curl -y

# Python Virtual Environment
echo -e "\n[2/7] Setting up Python Virtual Environment..."
python3 -m venv "$HOME/fault_env"
source "$HOME/fault_env/bin/activate"
pip install --upgrade pip -q

# Build Fault from Source
echo -e "\n[3/7] Building Fault from Source..."
if [ ! -d "$HOME/Fault" ]; then
    git clone https://github.com/AUCOHL/Fault.git "$HOME/Fault" -q
fi
cd "$HOME/Fault"

# --- AUTOMATION: Force the version to match your installed compiler ---
# This detects your current swift version and writes it to .swift-version
# to bypass the version-mismatch error.
swift --version | head -n 1 | awk '{print $3}' | cut -d'.' -f1,2 > .swift-version
echo " Set .swift-version to $(cat .swift-version)"

echo "⏳ Compiling Fault (Swift build)..."
swift build -c release 

# Place the binary in the env
cp .build/release/fault "$HOME/fault_env/bin/fault"
chmod +x "$HOME/fault_env/bin/fault"
echo "✅ Fault binary compiled and installed to ~/fault_env/bin/."

# Icarus Verilog
echo -e "\n[4/7] Building Icarus Verilog from Source..."
if [ ! -d "$HOME/iverilog" ]; then
    git clone https://github.com/steveicarus/iverilog.git -q "$HOME/iverilog"
fi
cd "$HOME/iverilog"
sh autoconf.sh > /dev/null
./configure > /dev/null
make -j$(nproc) > /dev/null
sudo make install > /dev/null

# Rust and Quaigh
echo -e "\n[5/7] Installing Rust and Quaigh..."
if ! command -v cargo &> /dev/null; then
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y -q
    source "$HOME/.cargo/env"
fi
cargo install quaigh -q

# Yosys
echo -e "\n[6/7] Building Yosys from Source..."
if [ ! -d "$HOME/yosys" ]; then
    git clone --recurse-submodules https://github.com/YosysHQ/yosys.git -q "$HOME/yosys"
fi
cd "$HOME/yosys"
make config-clang > /dev/null
make -j$(nproc) > /dev/null
sudo make install > /dev/null

# Cleanup Phase
echo -e "\n[7/7] Cleanup Phase"
read -p "Delete source build folders (~/iverilog, ~/yosys, ~/Fault)? (y/n): " cleanup_confirm
if [[ $cleanup_confirm == [yY] ]]; then
    rm -rf "$HOME/iverilog" "$HOME/yosys" "$HOME/Fault"
    echo " Cleaned up."
fi

# 7. Final Verification
echo -e "\n================================================================"
echo "                ALL SYSTEMS GO! Verification Summary:"
echo "====================================================================="
echo "📍 Fault:        $(~/fault_env/bin/fault --version)"
echo "📍 Yosys:        $(yosys -V)"
echo "📍 Icarus:       $(iverilog -V | head -n 1)"
echo "====================================================================="
echo " To work, run: source ~/fault_env/bin/activate && source ~/.cargo/env"
echo "====================================================================="
