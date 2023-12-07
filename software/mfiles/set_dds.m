%--------------------------------------------------------------------------
% User Interface Functions: 64-Channel DAQ Rev 2
%       Updated: 6/30/23 for 2023_DAQ_64_v2 Vivado project
%--------------------------------------------------------------------------
% Set DDS Frequencies
%--------------------------------------------------------------------------
% Inputs: cmdT (UI command set)
%       uart_port (serial port to FPGA)
%       enable_freqsweep (true to run frequency sweep, false to set indiv)
%       freqs (up to 2 frequency indices, required if enable_freqsweep is false)
%           NOTE: freqs(1) is 1st DDS frequency, freqs(2) is 2nd DDS frequency
%--------------------------------------------------------------------------
function [] = set_dds(cmdT,uart_port,enable_freqsweep,freqs,use_dual)

% Check use_dual input
if ~exist('use_dual','var')
    if length(freqs) > 1
        use_dual = 1;
    else
        use_dual = 0;
    end
elseif length(freqs) == 1
    freqs(2) = freqs;   % set second freq
end
%--------------------------------------------------------------------------
% Set first DDS
% If enable_freqsweep is true, run frequency sweep
if enable_freqsweep
    write(uart_port,cmdT.UI_EN_FREQ_SWEEP,'uint8');

% otherwise, set DDS cores individually
else 
    write(uart_port,cmdT.UI_DIS_FREQ_SWEEP,'uint8');
    write(uart_port,cmdT.UI_SET_FREQ_1,'uint8')  % Set frequency 1
    write(uart_port,freqs(1)-1,'uint8')
end
%--------------------------------------------------------------------------
% Set second DDS
if use_dual
    write(uart_port,cmdT.UI_SET_FREQ_2,'uint8')  % Set frequency 2
    write(uart_port,freqs(2)-1,'uint8')
else
    write(uart_port,cmdT.UI_DIS_FREQ_2,'uint8')  % Disable dds 2
end
%--------------------------------------------------------------------------