# SpaceEITDAQ

VHDL code developed for the Trenz Electronics TE0703-06/TE0711-01 Artix-7 FPGA boards can be downloaded here. This code is implemented on the FPGA for the space-deployable FPGA-based EIT DAQ.

MATLAB UI code to control the DAQ is also available for download. The main GUI provides all functionality needed to configure the system and run acquisition.

Software versions used:
- Vivado 2022.2
- MATLAB R2023b



File structure:
- analysis/: MATLAB scripts containing code used for analysis figures in thesis
- hardware/: Hardware files for Artix-7 FPGA
    - sim/: VHDL testbench files
    - src/: VHDL source files
    - top_top_design.bit (bitstream file for TE0711-01 FPGA board)
- software/: MATLAB code for DAQ GUI
    - mfiles/: functions called by the UI for DAQ and GUI controls
    - main_gui_functions.m (function called by GUI when Start button is pressed)
    - main_gui.mlapp (MATLAB App, main GUI)
