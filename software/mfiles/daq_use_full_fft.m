%--------------------------------------------------------------------------
% User Interface Functions: 64-Channel DAQ Rev 2
%--------------------------------------------------------------------------
% Set DAQ to use data from full FFT spectrum (all bins) for THD calculation
%--------------------------------------------------------------------------
% Inputs: cmdT (UI command set)
%       uart_port (serial port to FPGA)
%--------------------------------------------------------------------------
function [] = daq_use_full_fft(cmdT,uart_port)

write(uart_port,cmdT.UI_USE_FULL_FFT,'uint8')
disp('Using data from full FFT spectrum (all bins) for THD calculation')

%--------------------------------------------------------------------------