%--------------------------------------------------------------------------
% User Interface Functions: 64-Channel DAQ Rev 2
%       Updated: 6/30/23 for 2023_DAQ_64_v2 Vivado project
%--------------------------------------------------------------------------
% Set Mux Channels (1:64 to set mux channel, 0 to turn off), no display
%--------------------------------------------------------------------------
% Inputs: cmdT (UI command set)
%       uart_port (serial port to FPGA)
%       iivv (mux channels to set, 1:64, set to 0 to disable)
%       set_ii (0: set vv channels only, 1: disable first, then set all)
%--------------------------------------------------------------------------
function [] = set_muxes_iivv(cmdT,uart_port,iivv,set_ii)

%--------------------------------------------------------------------------
% Set source pair
if set_ii
    % Disable muxes first
    write(uart_port,cmdT.UI_DISABLE_MUXES,'uint8') 
    % Set muxes: inputs are 1-64, send integers 0:63 to FPGA
    if iivv(1) > 0
        write(uart_port,cmdT.UI_SET_MUX_VSRC,'uint8')    % Set Vsource mux
        write(uart_port,iivv(1)-1,'uint8')
    end
    if iivv(2) > 0
        write(uart_port,cmdT.UI_SET_MUX_VSINK,'uint8')   % Set Vsink mux
        write(uart_port,iivv(2)-1,'uint8')
    end
end

%--------------------------------------------------------------------------
% Set pickup pair
if iivv(3) > 0
    write(uart_port,cmdT.UI_SET_MUX_VPU1,'uint8')    % Set Vpickup Ch 1 mux
    write(uart_port,iivv(3)-1,'uint8')
end
if iivv(4) > 0
    write(uart_port,cmdT.UI_SET_MUX_VPU2,'uint8')    % Set Vpickup Ch 2 mux
    write(uart_port,iivv(4)-1,'uint8')
end

% Enable
write(uart_port,cmdT.UI_ENABLE_MUXES,'uint8') 

%--------------------------------------------------------------------------