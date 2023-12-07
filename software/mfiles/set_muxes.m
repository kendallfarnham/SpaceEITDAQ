%--------------------------------------------------------------------------
% User Interface Functions: 64-Channel DAQ Rev 2
%       Updated: 6/30/23 for 2023_DAQ_64_v2 Vivado project
%--------------------------------------------------------------------------
% Set Mux Channels (1:64 to set mux channel, 0 to turn off)   
%--------------------------------------------------------------------------
% Inputs: cmdT (UI command set)
%       uart_port (serial port to FPGA)
%       vsrc, vsink, vpu1, vpu2 (mux channels to set)
%       disable_before_set (disable all first, then set)
%--------------------------------------------------------------------------
function [] = set_muxes(cmdT,uart_port,vsrc,vsink,vpu1,vpu2,disable_before_set)

if disable_before_set
    write(uart_port,cmdT.UI_DISABLE_MUXES,'uint8') 
    disp('Muxes turned off before setting channels.')
end

% Set muxes: inputs are 1-64, send integers 0:63 to FPGA
if vsrc > 0
    write(uart_port,cmdT.UI_SET_MUX_VSRC,'uint8')    % Set Vsource mux
    write(uart_port,vsrc-1,'uint8')
end
if vsink > 0
    write(uart_port,cmdT.UI_SET_MUX_VSINK,'uint8')   % Set Vsink mux
    write(uart_port,vsink-1,'uint8')
end
if vpu1 > 0
    write(uart_port,cmdT.UI_SET_MUX_VPU1,'uint8')    % Set Vpickup Ch 1 mux
    write(uart_port,vpu1-1,'uint8')
end
if vpu2 > 0
    write(uart_port,cmdT.UI_SET_MUX_VPU2,'uint8')    % Set Vpickup Ch 2 mux
    write(uart_port,vpu2-1,'uint8')
end

write(uart_port,cmdT.UI_ENABLE_MUXES,'uint8') % enable muxes

disp(['Muxes with Ch > 0 enabled: [VS+ VS- V1 V2] = [' num2str(vsrc)  ...
    ' ' num2str(vsink) ' ' num2str(vpu1*2-1) ' ' num2str(vpu2*2) ']'])

end
%--------------------------------------------------------------------------