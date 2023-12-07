%--------------------------------------------------------------------------
% User Interface Functions: 64-Channel DAQ Rev 2
%       Updated: 6/30/23 for 2023_DAQ_64_v2 Vivado project
%--------------------------------------------------------------------------
% Divide DDS internally by 1, 2, 4, or 8 (inputs 0:3 for bit shifting)
%--------------------------------------------------------------------------
% Inputs: cmdT (UI command set)
%       uart_port (serial port to FPGA)
%       dds_shift_bits (number of bits to shift 0:3)
%--------------------------------------------------------------------------
function [] = set_dds_divide(cmdT,uart_port, dds_shift_bits)
    eval(['write(uart_port,cmdT.UI_DDS_DIVIDE_', num2str(dds_shift_bits), ',''uint8'')']);
end
%--------------------------------------------------------------------------