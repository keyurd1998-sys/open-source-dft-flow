# open-source-dft-flow
End-to-end FSM Design-for-Test (DFT) flow using Yosys and Fault including synthesis, ATPG, scan chain, JTAG, and simulation.

FSM DFT Flow – Complete Reference Guide
🔹 Project Overview

This project demonstrates a complete Design-for-Test (DFT) flow on Finite State Machines (FSMs) including:

RTL design (Mealy & Moore FSM)
Logic synthesis
Fault modeling & ATPG
Scan chain insertion
JTAG integration
Area analysis
Schematic generation
Simulation & verification

The goal is to provide a reusable reference flow for anyone working on DFT using open-source tools like Yosys and Fault.


////////////////////////////////////////////
///////////////////////////////////////////  
🚀 Getting Started (Clone & Setup)
📥 Clone the Repository

┌──(kali㉿keyur)-[~]
└─$ git clone https://github.com/keyurd1998-sys/open-source-dft-flow.git

┌──(kali㉿keyur)-[~]
└─$ cd open-source-dft-flow


////////////////////////////////////////////
///////////////////////////////////////////                                                                                                                          
lib/              → Standard cell library (.lib and .v)
rtl/              → RTL design files (Mealy & Moore FSM)
State_Diagram/    → FSM state diagrams & state tables
   
                     
┌──(kali㉿keyur)-[~/open-source-dft-flow]
└─$ tree
.
├── lib
│   ├── osu035_stdcells.lib
│   └── osu035_stdcells.v
├── rtl
│   ├── mealy_fsm_rtl.v
│   └── moore_fsm_rtl.v
└── State_Diagram
    ├── Mealy
    │   ├── mealy_fsm_state_diagram.png
    │   └── mealy_fsm_state_table.png
    └── Moore
        ├── moore_fsm_stste_diagram.png
        └── Moore_State_Table.png


////////////////////////////////////////////
///////////////////////////////////////////
⚠️ Important Setup Note
This project uses the Fault DFT tool installed locally (NOT Docker-based).
It is executed inside a Python virtual environment, along with required system dependencies (Yosys, Icarus Verilog, Graphviz, etc.).

👉 Before running any commands, make sure to activate the environment:
 

┌──(kali㉿keyur)-[~/open-source-dft-flow]
└─$ source ~/fault_env/bin/activate && source $HOME/.cargo/env
  
⚠️ Running without activating the environment may lead to command not found / dependency errors.
////////////////////////////////////////////
///////////////////////////////////////////
1️⃣ Directory Initialization
Create working folders for each stage of the flow:

                                                                                                                                               
┌──(fault_env)─(kali㉿keyur)-[~/open-source-dft-flow]
└─$ mkdir synth cut scan JTAG logs report atpg schematic simulation

////////////////////////////////////////////
///////////////////////////////////////////
2️⃣ RTL Synthesis

Convert RTL → Gate-level netlist using standard cell library:


┌──(fault_env)─(kali㉿keyur)-[~/open-source-dft-flow]
└─$ fault synth -t mealy_fsm -l lib/osu035_stdcells.lib -o synth/mealy_fsm_netlist.v rtl/mealy_fsm_rtl.v 2>&1 | tee logs/synth.log


📌 Output:
1.Gate-level netlist
2.Synthesis log
////////////////////////////////////////////
///////////////////////////////////////////
3️⃣ Fault Cut (DFT Preparation)
Prepare design for ATPG by isolating sequential elements:


┌──(fault_env)─(kali㉿keyur)-[~/open-source-dft-flow]
└─$ fault cut --clock clk --reset reset -o cut/mealy_fsm_cut_netlist.v synth/mealy_fsm_netlist.v 2>&1 | tee logs/cut.log


📌 Purpose:
Converts design into a testable model
////////////////////////////////////////////
///////////////////////////////////////////
4️⃣ ATPG (Automatic Test Pattern Generation)
Generate test vectors for fault coverage:

┌──(fault_env)─(kali㉿keyur)-[~/open-source-dft-flow]
└─$ fault atpg \                                                                                                        
  --cell-model lib/osu035_stdcells.v \
  --tv-count 50 --increment 100 --min-coverage 100 --ceiling 1000\ 
  --clock clk \
  --reset reset \
  -o atpg/mealy_fsm_pattern.json \
  --output-coverage-metadata report/atpg_fault_metadata.yml \
  cut/mealy_fsm_cut_netlist.v \
  2>&1 | tee logs/atpg.log


📌 Output:
1.Test patterns
2.Fault coverage report
////////////////////////////////////////////
///////////////////////////////////////////
5️⃣ Scan Chain Insertion
Insert scan chains for controllability & observability:

  
┌──(fault_env)─(kali㉿keyur)-[~/open-source-dft-flow]
└─$ fault chain -l lib/osu035_stdcells.lib -c lib/osu035_stdcells.v --clock clk --reset reset --activeLow -o scan/chain_inserted_netlist.v  synth/mealy_fsm_netlist.v 2>&1 | tee logs/chain.log


📌 Result:
Flip-flops converted to scan FFs
////////////////////////////////////////////
///////////////////////////////////////////
6️⃣ JTAG Integration
Wrap design with JTAG interface:


┌──(fault_env)─(kali㉿keyur)-[~/open-source-dft-flow]
└─$ fault tap --clock clk --reset reset --activeLow\
  -l lib/osu035_stdcells.lib -c lib/osu035_stdcells.v \
  -o JTAG/JTAG_wrapped_netlist.v scan/chain_inserted_netlist.v 2>1 | tee logs/tap.log


📌 Adds:
1.TAP controller
2.Boundary scan access
////////////////////////////////////////////
///////////////////////////////////////////
7️⃣ Area Analysis
Compare area before & after DFT:

Before DFT:

┌──(fault_env)─(kali㉿keyur)-[~/open-source-dft-flow]
└─$ yosys -p "read_verilog synth/mealy_fsm_netlist.v; stat -liberty lib/osu035_stdcells.lib" > report/area_report_initial.txt

After DFT:
                                                                                                                                                    
┌──(fault_env)─(kali㉿keyur)-[~/open-source-dft-flow]
└─$ yosys -p "read_verilog JTAG/JTAG_wrapped_netlist.v; stat -liberty lib/osu035_stdcells.lib" > report/area_report_final.txt


📌 Insight:
DFT overhead (scan + JTAG)
////////////////////////////////////////////
///////////////////////////////////////////
8️⃣ Schematic Generation
Generate visual representation of synthesized design:


┌──(fault_env)─(kali㉿keyur)-[~/open-source-dft-flow]
└─$ yosys -p "read_liberty -lib lib/osu035_stdcells.lib; read_verilog synth/mealy_fsm_netlist.v; hierarchy -top mealy_fsm; proc; opt; clean; show -format dot -prefix schematic/mealy_fsm_synth_schematic" && dot -Tsvg -Gsplines=ortho -Grankdir=LR -Gnodesep=1.5 -Granksep=1 -Gconcentrate=true -Nshape=record -Gmcmitersize=10 -o schematic/mealy_fsm_synth_schematic.svg schematic/mealy_fsm_synth_schematic.dot


📌 Output:
Clean schematic for debugging
////////////////////////////////////////////
///////////////////////////////////////////
9️⃣ Simulation
Compile and run simulations:


┌──(fault_env)─(kali㉿keyur)-[~/open-source-dft-flow]
└─$ iverilog -D VCD -o simulation/chain_sim scan/chain_inserted_netlist.v.tb.sv

┌──(fault_env)─(kali㉿keyur)-[~/open-source-dft-flow]
└─$ iverilog -D VCD -o simulation/JTAG_sim JTAG/JTAG_wrapped_netlist.v.tb.sv

┌──(fault_env)─(kali㉿keyur)-[~/open-source-dft-flow]
└─$ cd simulation

┌──(fault_env)─(kali㉿keyur)-[~/open-source-dft-flow/simulation]
└─$ vvp JTAG_sim

┌──(fault_env)─(kali㉿keyur)-[~/open-source-dft-flow/simulation]
└─$ vvp chain_sim

┌──(fault_env)─(kali㉿keyur)-[~/open-source-dft-flow/simulation]
└─$ cd ../


📌 Output:
VCD waveform files for analysis
////////////////////////////////////////////
///////////////////////////////////////////
📊 Final Outputs Summary
| Stage      | Output                    |
| ---------- | ------------------------- |
| Synthesis  | Gate-level netlist        |
| Cut        | Testable netlist          |
| ATPG       | Test vectors + coverage   |
| Scan       | Scan-inserted design      |
| JTAG       | Fully testable chip model |
| Report     | Area & fault coverage     |
| Simulation | Functional verification   |


┌──(fault_env)─(kali㉿keyur)-[~/open-source-dft-flow]
└─$ tree
.
├── atpg
│   ├── mealy_fsm_pattern.json
│   └── mealy_fsm_pattern.json.raw_tv.json
├── cut
│   └── mealy_fsm_cut_netlist.v
├── JTAG
│   ├── JTAG_wrapped_netlist.v
│   ├── JTAG_wrapped_netlist.v+attrs
│   ├── JTAG_wrapped_netlist.v.jtag_intermediate.v
│   ├── JTAG_wrapped_netlist.v.tb.sv
│   └── JTAG_wrapped_netlist.v.tb.sv.log
├── lib
│   ├── osu035_stdcells.lib
│   └── osu035_stdcells.v
├── logs
│   ├── atpg.log
│   ├── chain.log
│   ├── cut.log
│   ├── synth.log
│   └── tap.log
├── parser.out
├── parsetab.py
├── report
│   ├── area_report_final.txt
│   ├── area_report_initial.txt
│   └── atpg_fault_metadata.yml
├── rtl
│   ├── mealy_fsm_rtl.v
│   └── moore_fsm_rtl.v
├── scan
│   ├── chain_inserted_netlist.v
│   ├── chain_inserted_netlist.v+attrs
│   ├── chain_inserted_netlist.v.chain-intermediate.v
│   ├── chain_inserted_netlist.v.tb.sv
│   └── chain_inserted_netlist.v.tb.sv.log
├── schematic
│   ├── fsm_schematic_synth.dot
│   ├── mealy_fsm_synth_schematic.dot
│   └── mealy_fsm_synth_schematic.svg
├── simulation
│   ├── chain_sim
│   ├── chain.vcd
│   ├── dut.vcd
│   └── JTAG_sim
├── State_Diagram
│   ├── Mealy
│   │   ├── mealy_fsm_state_diagram.png
│   │   └── mealy_fsm_state_table.png
│   └── Moore
│       ├── moore_fsm_stste_diagram.png
│       └── Moore_State_Table.png
└── synth
    ├── mealy_fsm_netlist.v
    └── mealy_fsm_netlist.v+attrs

15 directories, 40 files



