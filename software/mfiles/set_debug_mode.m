%--------------------------------------------------------------------------
% User Interface Functions: 64-Channel DAQ Rev 2
%       Updated: 6/30/23 for 2023_DAQ_64_v2 Vivado project
%--------------------------------------------------------------------------
% Send DDS to Demod block (no AFE involved) for debug mode
%--------------------------------------------------------------------------
% Inputs: cmdT (UI command set)
%       uart_port (serial port to FPGA)
%       enable_debug_mode (enable DDS to demod debug mode)
%       enable_adout_n (enable send raw data from one ADC)
%--------------------------------------------------------------------------
function [] = set_debug_mode(cmdT,uart_port,enable_debug_mode,enable_adout_n)

    if exist('enable_adout_n','var')
        switch enable_adout_n
            case 0 
                write(uart_port,cmdT.UI_SET_ADOUT_0,'uint8');
            case 1
                write(uart_port,cmdT.UI_SET_ADOUT_1,'uint8');
            case 2
                write(uart_port,cmdT.UI_SET_ADOUT_2,'uint8');
            case 3
                write(uart_port,cmdT.UI_SET_ADOUT_3,'uint8');
            otherwise
                write(uart_port,cmdT.UI_SET_ADOUT_0,'uint8');
                disp('ADC number out of range. Select 1-3 to enable adc data out.')
        end
    end

    % Set dds to adc mode
    if enable_debug_mode
        write(uart_port,cmdT.UI_EN_DEBUG_MODE,'uint8');
    else
        write(uart_port,cmdT.UI_DIS_DEBUG_MODE,'uint8');
    end
end
%--------------------------------------------------------------------------