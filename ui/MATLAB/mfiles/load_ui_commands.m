%--------------------------------------------------------------------------
% User Interface Functions: 64-Channel DAQ Rev 2
%       Updated: 6/30/23 for 2023_DAQ_64_v2 Vivado project
%--------------------------------------------------------------------------
% Load UI command set
%--------------------------------------------------------------------------
% Outputs: cmdT (UI command set)
%--------------------------------------------------------------------------
function [cmdT] = load_ui_commands()
%--------------------------------------------------------------------------
% Define user input commands and save to cmdT object
%--------------------------------------------------------------------------
% GLOBAL COMMANDS:
CMD_IDX_0 = 128;                 % index of first command
cmdT.UI_RESET = CMD_IDX_0;       % reset
cmdT.UI_ENABLE = CMD_IDX_0+1;    % enable
cmdT.UI_DISABLE = CMD_IDX_0+2;   % disable all
cmdT.UI_EN_TX = CMD_IDX_0+3;     % enable transfer to MATLAB
cmdT.UI_DIS_TX = CMD_IDX_0+4;    % stop transfer to MATLAB
%--------------------------------------------------------------------------
% DDS COMMANDS:
cmdT.UI_EN_FREQ_SWEEP = CMD_IDX_0+32;    % enable monotone frequency sweep
cmdT.UI_DIS_FREQ_SWEEP = CMD_IDX_0+33;   % disable monotone frequency sweep
cmdT.UI_SET_FREQ_1 = CMD_IDX_0+34;       % set first frequency index
cmdT.UI_SET_FREQ_2 = CMD_IDX_0+35;       % set second frequency index
cmdT.UI_EN_FREQ_2 = CMD_IDX_0+36;        % enable second frequency
cmdT.UI_DIS_FREQ_2 = CMD_IDX_0+37;       % disable second frequency
cmdT.UI_DDS_DIVIDE_1 = CMD_IDX_0+11;     % divide DDS output by 1
cmdT.UI_DDS_DIVIDE_2 = CMD_IDX_0+12;     % divide DDS output by 2
cmdT.UI_DDS_DIVIDE_3 = CMD_IDX_0+13;     % divide DDS output by 3
cmdT.UI_DDS_DIVIDE_4 = CMD_IDX_0+14;     % divide DDS output by 4
%--------------------------------------------------------------------------
% DATA ACQUISITION SETTINGS
cmdT.UI_SET_N_AVGS = CMD_IDX_0+15;       % set number of datasets to average
cmdT.UI_SET_ADOUT_0 = CMD_IDX_0+16;      % send no ADC data out
cmdT.UI_SET_ADOUT_1 = CMD_IDX_0+17;      % send Isense ADC data out
cmdT.UI_SET_ADOUT_2 = CMD_IDX_0+18;      % send Vpickup Ch1 ADC data out
cmdT.UI_SET_ADOUT_3 = CMD_IDX_0+19;      % send Vpickup Ch2 ADC data out
cmdT.UI_USE_FULL_FFT = CMD_IDX_0+20;     % use full FFT spectrum for calcs
cmdT.UI_SET_N_DSETS = CMD_IDX_0+21;      % set number of datasets to acquire
%--------------------------------------------------------------------------
% ADC COMMANDS:
cmdT.UI_ADC_TESTPAT_ON = CMD_IDX_0+5;    % testpattern on
cmdT.UI_ADC_TESTPAT_OFF = CMD_IDX_0+6;   % testpattern off - default
cmdT.UI_EN_DEBUG_MODE = CMD_IDX_0+7;     % enable adc debug mode (dds to demod block)
cmdT.UI_DIS_DEBUG_MODE = CMD_IDX_0+8;    % disable adc debug mode
cmdT.UI_ADC_POWER_OFF = CMD_IDX_0+9;     % power down adcs
cmdT.UI_ADC_POWER_ON = CMD_IDX_0+10;     % power on adcs
%--------------------------------------------------------------------------
% PGA COMMANDS:
cmdT.UI_SET_PGA_ISENSE = CMD_IDX_0+38;   % set Isense PGA gain
cmdT.UI_SET_PGA_VPU1 = CMD_IDX_0+39;     % set Vpickup Ch 1 PGA gain
cmdT.UI_SET_PGA_VPU2 = CMD_IDX_0+40;     % set Vpickup Ch 2 PGA gain
%--------------------------------------------------------------------------
% MUX COMMANDS:
cmdT.UI_SET_MUX_VSRC = CMD_IDX_0+41;     % set Vsource mux
cmdT.UI_SET_MUX_VSINK = CMD_IDX_0+42;    % set Vsink mux
cmdT.UI_SET_MUX_VPU1 = CMD_IDX_0+43;     % set Vpickup Ch 1 mux
cmdT.UI_SET_MUX_VPU2 = CMD_IDX_0+44;     % set Vpickup Ch 2 mux
cmdT.UI_DISABLE_MUXES = CMD_IDX_0+45;    % Disable all muxes
cmdT.UI_ENABLE_MUXES = CMD_IDX_0+46;     % Enable muxes

end
%--------------------------------------------------------------------------