%--------------------------------------------------------------------------
% User Interface Functions: 64-Channel DAQ Rev 2
%       Updated: 6/30/23 for 2023_DAQ_64_v2 Vivado project
%--------------------------------------------------------------------------
% Enable DAQ/FPGA
%--------------------------------------------------------------------------
% Inputs: cmdT (UI command set)
%       uart_port (serial port to FPGA)
%--------------------------------------------------------------------------
function [] = daq_enable(cmdT,uart_port)
    write(uart_port,cmdT.UI_ENABLE,'uint8')
end
%--------------------------------------------------------------------------