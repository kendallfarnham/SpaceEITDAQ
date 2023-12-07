%--------------------------------------------------------------------------
% User Interface Functions: 64-Channel DAQ Rev 2
%       Updated: 6/30/23 for 2023_DAQ_64_v2 Vivado project
%--------------------------------------------------------------------------
% Set PGA gains (inputs are 1:8, pga_gains = [1 2 4 5 8 10 16 32])
%--------------------------------------------------------------------------
% Inputs: cmdT (UI command set)
%       uart_port (serial port to FPGA)
%       isense vpu1, vpu2 (pgas to set)
%--------------------------------------------------------------------------
function [] = set_pga_gains(cmdT,uart_port,isense,vpu1,vpu2)

% Set PGA gains (inputs are 1:8, send integers 0:7)
    write(uart_port,cmdT.UI_SET_PGA_ISENSE,'uint8')  % Set Isense PGA gain
    write(uart_port,isense-1,'uint8')
    % write(uart_port,dec2bin(isense-1,8),'string')
    % pause(0.5)
    write(uart_port,cmdT.UI_SET_PGA_VPU1,'uint8')    % Set Vpickup Ch 1 PGA gain
    write(uart_port,vpu1-1,'uint8')
    % write(uart_port,dec2bin(vpu1-1,8),'string')
    % pause(0.5)
    write(uart_port,cmdT.UI_SET_PGA_VPU2,'uint8')    % Set Vpickup Ch 2 PGA gain
    write(uart_port,vpu2-1,'uint8')
    % write(uart_port,dec2bin(vpu2-1,8),'string')
end
%--------------------------------------------------------------------------