%--------------------------------------------------------------------------
% User Interface Functions: 64-Channel DAQ Rev 2
%       Updated: 8/21/23 for 2023_DAQ Vivado project
%--------------------------------------------------------------------------
% Set number of datasets to acquire per fsm loop
%--------------------------------------------------------------------------
% Inputs: cmdT (UI command set)
%       uart_port (serial port to FPGA)
%       nsets (number of datasets to acquire)
%--------------------------------------------------------------------------
function [] = set_ndatasets(cmdT,uart_port,nsets)

write(uart_port,cmdT.UI_SET_N_DSETS,'uint8') 
write(uart_port,nsets,'uint8')

%--------------------------------------------------------------------------