# 🛡️ Open-Source DFT Flow (FSM Focus)

[![Tools](https://img.shields.io/badge/Tools-Yosys%20%7C%20Fault%20%7C%20Icarus-blue)](#)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![OS](https://img.shields.io/badge/OS-Ubuntu%20%7C%20Debian-orange)](#)

An end-to-end **Design-for-Test (DFT)** methodology for Finite State Machines (FSMs). This repository provides a complete open-source pipeline for synthesis, scan-insertion, ATPG, and JTAG integration.

---

## 🛠️ Project Overview
Testing is a critical phase in the silicon lifecycle. This project demonstrates a hardware-agnostic flow using **Yosys** and **Fault** to transform high-level RTL into testable silicon netlists. It is designed to be a reusable reference for academic and professional VLSI research.

### Key Features:
* **FSM Support:** Verified for both Mealy and Moore architectures.
* **Logic Synthesis:** Standard cell mapping using Yosys.
* **DFT Insertion:** Automated Scan Chain stitching and JTAG (TAP) integration.
* **ATPG:** High-coverage pattern generation for stuck-at fault models.
* **Analytics:** Area analysis, schematic generation, and formal verification.

---

## 🏗️ The DFT Pipeline
The flow follows a standard industry-like sequence:

1.  **RTL Design:** Input FSM Verilog code.
2.  **Synthesis:** Convert RTL to gate-level netlists via **Yosys**.
3.  **DFT Insertion:** Insert scan-chains and JTAG controllers using **Fault**.
4.  **ATPG:** Generate test patterns for fault coverage.
5.  **Verification:** Simulation and JTAG validation via **Icarus Verilog**.

---

## 🚀 Getting Started

### 1. Clone the Repository
```bash
git clone [https://github.com/keyurd1998-sys/open-source-dft-flow.git](https://github.com/keyurd1998-sys/open-source-dft-flow.git)
cd open-source-dft-flow
```
---

## 📥 Local Environment Setup
This project bypasses Docker to run natively on your OS for maximum performance. The setup script automates the installation of the Fault DFT tool, Yosys, and Icarus Verilog within a dedicated Python virtual environment.
```bash
# Provide execution permissions
chmod +x fault_installation.sh

# Execute the installation
./fault_installation.sh
```
---

🕒 Note on Duration: Because Yosys and Icarus are built from source to ensure compatibility with the latest PDKs, this process can take 60 to 90 minutes depending on your CPU.

⚠️ System Resources: The script uses $(nproc) to compile at maximum speed. It is highly recommended to close browsers and other heavy applications to prevent system hangs during compilation.

---

##  Activate Fault_Environment

Crucial: You must activate the environment in every new terminal session to link the hardware binaries and Python libraries.
```bash
source ~/fault_env/bin/activate && source $HOME/.cargo/env
```

---
