%--------------------------------------------------------------------------
% User Interface Functions: 64-Channel DAQ Rev 2
%       Updated: 6/30/23 for 2023_DAQ_64_v2 Vivado project
%--------------------------------------------------------------------------
% Turn on ADC testpattern for debug mode
%--------------------------------------------------------------------------
% Inputs: cmdT (UI command set)
%       uart_port (serial port to FPGA)
%       testpat_on (turn on ADC testpattern if true/1)
%--------------------------------------------------------------------------
function [] = set_adc_testpattern(cmdT,uart_port,testpat_on)
    if testpat_on 
        write(uart_port,cmdT.UI_ADC_TESTPAT_ON,'uint8');  % turn on ADC testpattern
        disp('ADC testpattern on.')
    else
        write(uart_port,cmdT.UI_ADC_TESTPAT_OFF,'uint8');  % turn off ADC testpattern
    end
end
%--------------------------------------------------------------------------