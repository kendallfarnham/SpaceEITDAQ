%--------------------------------------------------------------------------
% User Interface Functions: 64-Channel DAQ Rev 2
%--------------------------------------------------------------------------
% Load UI command set for GUI
%--------------------------------------------------------------------------
% Outputs: ui_params (UI command set)
%--------------------------------------------------------------------------
function [ui_params] = load_default_gui_params()
%--------------------------------------------------------------------------
% Define user input commands and save to cmdT object
%--------------------------------------------------------------------------
ui_params(1).nsets = 1;    % SET NUMBER OF DATASETS TO ACQUIRE
ui_params(1).navgs = 4;   % SET NUMBER OF AVERAGES TO COMPUTE
ui_params(1).ii_filename = 'coe\ii_pairs_ch1-16_skip3.csv';
ui_params(1).enable_freqsweep = 1;
ui_params(1).use_dual = 0;
ui_params(1).freq1_inds = 1;
ui_params(1).freq2_inds = [];
ui_params(1).save_data = 1;
ui_params(1).sfolder = 'mat/debug_data/';
ui_params(1).sfile_pfx = 'dataset_1';
ui_params(1).plot_data = 1;
ui_params(1).use_full_fft = 1;
ui_params(1).use_fsig_bins = 3;
ui_params(1).reset = 1;
ui_params(1).disable_after_run = 1;
ui_params(1).adc_testpattern_on = 0;
ui_params(1).enable_dds_to_fft = 0;
ui_params(1).enable_adc_out = 0;
ui_params(1).save_log = 0;
debug_mode = 1;
sfile_loc = [ui_params(1).sfolder ui_params(1).sfile_pfx '.mat'];