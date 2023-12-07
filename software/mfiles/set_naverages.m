%--------------------------------------------------------------------------
% User Interface Functions: 64-Channel DAQ Rev 2
%       Updated: 8/21/23 for 2023_DAQ Vivado project
%--------------------------------------------------------------------------
% Set number of averages (datasets to acquire per fsm loop) 
%--------------------------------------------------------------------------
% Inputs: cmdT (UI command set)
%       uart_port (serial port to FPGA)
%       navgs (number of averages to acquire)
%--------------------------------------------------------------------------
function [] = set_naverages(cmdT,uart_port,navgs)

write(uart_port,cmdT.UI_SET_N_AVGS,'uint8') 
write(uart_port,navgs,'uint8')

%--------------------------------------------------------------------------