%--------------------------------------------------------------------------
% User interface for 2023_DAQ
%   Extract voltages and currents and save workspace for plotting data on
%   the DAQ GUI or plot_thesis_daq_performance.m
%--------------------------------------------------------------------------
% Inputs: folder_data (extracted struct of adc data vpp_i, vpp_v1, vpp_v2, etc)
%       save_path (save workspace variables here)
%       board_num (AFE board used)
%       avg_datasets (average the data per frequency)
% Optional inputs:
%       rm_outliers (remove data outside prange)
%       kp_inds (keep these freq indices)
%       prange (if rm_outliers, remove data outside this range)
%--------------------------------------------------------------------------
function extract_plot_variables(folder_data,save_path,board_num, ...
    avg_datasets,rm_outliers,kp_inds,prange)
%--------------------------------------------------------------------------
% Check inputs
%--------------------------------------------------------------------------
freqs = folder_data(1).freqs;
nsets = folder_data(1).nsets;
if ~exist('avg_datasets','var')
    if nsets > 1; avg_datasets = 1; else; avg_datasets = 0; end
end
%--------------------------------------------------------------------------
% Optional
if ~exist('rm_outliers','var'); rm_outliers = 0; end % don't remove outliers
if ~exist('kp_inds','var'); kp_inds = 1:length(freqs); end % keep all frequency indices
if ~exist('prange','var'); prange = [0 1]; end % keep all data (percentile range 100%)
%--------------------------------------------------------------------------
% Load AFE circuit parameters
[afe_params] = get_circuit_parameters(board_num);
Rsense = afe_params.Rsense;         % sense resistor value
Rvpickup = afe_params.Rvpickup;     % vpickup circuit input resistance
%--------------------------------------------------------------------------
% Extract voltages
for k = 1:length(folder_data)
    nsets = folder_data(k).nsets;
    %--------------------------------------------------------------------------
    % Extract load impedance, calculate snar and precision
    rload = (folder_data(k).vload_vpp)./(folder_data(k).vpp_i/Rsense);
    % Rload_precision(k,:) = sqrt(sum(abs(Rload-mean(Rload)))/nsets);
    Rload_precision(k,:) = std(rload); % standard deviation
    Rload_snr(k,:) = 20*log10(mean(rload)./std(rload));


    %--------------------------------------------------------------------------
    % Extract voltages, currents, load
    if nsets == 1
        Visense(k,:) = folder_data(k).vpp_i;
        Vpickup1(k,:) = folder_data(k).vpp_v1;
        Vpickup2(k,:) = folder_data(k).vpp_v2;
        Visense_thd(k,:) = folder_data(k).thd_i;
        Vpickup1_thd(k,:) = folder_data(k).thd_v1;
        Vpickup2_thd(k,:) = folder_data(k).thd_v2;
        Vload_vpp(k,:) = folder_data(k).vload_vpp;
        % Vload_cal(k,:) = folder_data(k).vload_cal;
        % Iload_cal(k,:) = folder_data(k).iload_cal;
        % Rload_cal0(k,:) = folder_data(k).rload_cal;
        Rload0(k,:) = rload;
    elseif avg_datasets
        Visense(k,:) = mean(folder_data(k).vpp_i);
        Vpickup1(k,:) = mean(folder_data(k).vpp_v1);
        Vpickup2(k,:) = mean(folder_data(k).vpp_v2);
        Visense_thd(k,:) = mean(folder_data(k).thd_i);
        Vpickup1_thd(k,:) = mean(folder_data(k).thd_v1);
        Vpickup2_thd(k,:) = mean(folder_data(k).thd_v2);
        Vload_vpp(k,:) = mean(folder_data(k).vload_vpp);
        % Vload_cal(k,:) = mean(folder_data(k).vload_cal);
        % Iload_cal(k,:) = mean(folder_data(k).iload_cal);
        % Rload_cal0(k,:) = mean(folder_data(k).rload_cal);
        Rload0(k,:) = mean(rload);
    else
        Visense(k,:,:) = folder_data(k).vpp_i;
        Vpickup1(k,:,:) = folder_data(k).vpp_v1;
        Vpickup2(k,:,:) = folder_data(k).vpp_v2;
        Visense_thd(k,:,:) = folder_data(k).thd_i;
        Vpickup1_thd(k,:,:) = folder_data(k).thd_v1;
        Vpickup2_thd(k,:,:) = folder_data(k).thd_v2;
        Vload_vpp(k,:,:) = folder_data(k).vload_vpp;
        % Vload_cal(k,:,:) = folder_data(k).vload_cal;
        % Iload_cal(k,:,:) = folder_data(k).iload_cal;
        % Rload_cal0(k,:,:) = folder_data(k).rload_cal;
        Rload0(k,:,:) = rload;
    end

    %--------------------------------------------------------------------------
    % Extract voltage SNR
    Visense_snr(k,:) = folder_data(k).snr_i;
    Vpickup1_snr(k,:) = folder_data(k).snr_v1;
    Vpickup2_snr(k,:) = folder_data(k).snr_v2;
    vpp = folder_data(k).vload_vpp;
    Vload_snr(k,:) = 20*log10(mean(vpp)./std(vpp));
    Vload_precision(k,:) = std(vpp); % standard deviation


    %--------------------------------------------------------------------------
    % Extract SNRs for all demod data from FPGA
    Visense_snr_k1(k,:) = folder_data(k).avg_adc_data(1).snr_k1(1,:);
    Vpickup1_snr_k1(k,:) = folder_data(k).avg_adc_data(1).snr_k1(2,:);
    Vpickup2_snr_k1(k,:) = folder_data(k).avg_adc_data(1).snr_k1(3,:);
    Visense_snr_k2(k,:) = folder_data(k).avg_adc_data(1).snr_k2(1,:);
    Vpickup1_snr_k2(k,:) = folder_data(k).avg_adc_data(1).snr_k2(2,:);
    Vpickup2_snr_k2(k,:) = folder_data(k).avg_adc_data(1).snr_k2(3,:);
    Visense_snr_dc(k,:) = folder_data(k).avg_adc_data(1).snr_dc(1,:);
    Vpickup1_snr_dc(k,:) = folder_data(k).avg_adc_data(1).snr_dc(2,:);
    Vpickup2_snr_dc(k,:) = folder_data(k).avg_adc_data(1).snr_dc(3,:);
    Visense_snr_sum2(k,:) = folder_data(k).avg_adc_data(1).snr_mag2sum(1,:);
    Vpickup1_snr_sum2(k,:) = folder_data(k).avg_adc_data(1).snr_mag2sum(2,:);
    Vpickup2_snr_sum2(k,:) = folder_data(k).avg_adc_data(1).snr_mag2sum(3,:);

    % Extract precisions for all demod data from FPGA
    Visense_precision_k1(k,:) = folder_data(k).avg_adc_data(1).precision_k1(1,:);
    Vpickup1_precision_k1(k,:) = folder_data(k).avg_adc_data(1).precision_k1(2,:);
    Vpickup2_precision_k1(k,:) = folder_data(k).avg_adc_data(1).precision_k1(3,:);
    Visense_precision_k2(k,:) = folder_data(k).avg_adc_data(1).precision_k2(1,:);
    Vpickup1_precision_k2(k,:) = folder_data(k).avg_adc_data(1).precision_k2(2,:);
    Vpickup2_precision_k2(k,:) = folder_data(k).avg_adc_data(1).precision_k2(3,:);
    Visense_precision_dc(k,:) = folder_data(k).avg_adc_data(1).precision_dc(1,:);
    Vpickup1_precision_dc(k,:) = folder_data(k).avg_adc_data(1).precision_dc(2,:);
    Vpickup2_precision_dc(k,:) = folder_data(k).avg_adc_data(1).precision_dc(3,:);
    Visense_precision_sum2(k,:) = folder_data(k).avg_adc_data(1).precision_mag2sum(1,:);
    Vpickup1_precision_sum2(k,:) = folder_data(k).avg_adc_data(1).precision_mag2sum(2,:);
    Vpickup2_precision_sum2(k,:) = folder_data(k).avg_adc_data(1).precision_mag2sum(3,:);


    %--------------------------------------------------------------------------
    % Extract precision (mean +/- standard deviation) for all demod data from FPGA
    % Mean
    Visense_mean_k1(k,:) = folder_data(k).avg_adc_data(1).mean_fft_k1(1,:);
    Vpickup1_mean_k1(k,:) = folder_data(k).avg_adc_data(1).mean_fft_k1(2,:);
    Vpickup2_mean_k1(k,:) = folder_data(k).avg_adc_data(1).mean_fft_k1(3,:);
    Visense_mean_k2(k,:) = folder_data(k).avg_adc_data(1).mean_fft_k2(1,:);
    Vpickup1_mean_k2(k,:) = folder_data(k).avg_adc_data(1).mean_fft_k2(2,:);
    Vpickup2_mean_k2(k,:) = folder_data(k).avg_adc_data(1).mean_fft_k2(3,:);
    Visense_mean_dc(k,:) = folder_data(k).avg_adc_data(1).mean_fft_dc(1,:);
    Vpickup1_mean_dc(k,:) = folder_data(k).avg_adc_data(1).mean_fft_dc(2,:);
    Vpickup2_mean_dc(k,:) = folder_data(k).avg_adc_data(1).mean_fft_dc(3,:);
    Visense_mean_sum2(k,:) = folder_data(k).avg_adc_data(1).mean_mag2sum(1,:);
    Vpickup1_mean_sum2(k,:) = folder_data(k).avg_adc_data(1).mean_mag2sum(2,:);
    Vpickup2_mean_sum2(k,:) = folder_data(k).avg_adc_data(1).mean_mag2sum(3,:);
    % Standard deviation
    Visense_std_k1(k,:) = folder_data(k).avg_adc_data(1).stdev_fft_k1(1,:);
    Vpickup1_std_k1(k,:) = folder_data(k).avg_adc_data(1).stdev_fft_k1(2,:);
    Vpickup2_std_k1(k,:) = folder_data(k).avg_adc_data(1).stdev_fft_k1(3,:);
    Visense_std_k2(k,:) = folder_data(k).avg_adc_data(1).stdev_fft_k2(1,:);
    Vpickup1_std_k2(k,:) = folder_data(k).avg_adc_data(1).stdev_fft_k2(2,:);
    Vpickup2_std_k2(k,:) = folder_data(k).avg_adc_data(1).stdev_fft_k2(3,:);
    Visense_std_dc(k,:) = folder_data(k).avg_adc_data(1).stdev_fft_dc(1,:);
    Vpickup1_std_dc(k,:) = folder_data(k).avg_adc_data(1).stdev_fft_dc(2,:);
    Vpickup2_std_dc(k,:) = folder_data(k).avg_adc_data(1).stdev_fft_dc(3,:);
    Visense_std_sum2(k,:) = folder_data(k).avg_adc_data(1).stdev_mag2sum(1,:);
    Vpickup1_std_sum2(k,:) = folder_data(k).avg_adc_data(1).stdev_mag2sum(2,:);
    Vpickup2_std_sum2(k,:) = folder_data(k).avg_adc_data(1).stdev_mag2sum(3,:);
end


%--------------------------------------------------------------------------
% Calculate measured current (Isense) and load current (V1-V2)
Isense = Visense/Rsense;
Vload = Vpickup1 - Vpickup2;
Rload_est = Rload0;             % save from struct
Rload = Vload./Isense;          % estimated load impedance
% Iload = Vload./RLs;             % current across load

%--------------------------------------------------------------------------
% Calibration - new
% [Rload_cal, Rl_cf] = calibrate_rload(Rload,freqs,board_num);
[Rload_cal, Rl_cf, Vpu_Vdivide_gain] = calibrate_rload(Rload,freqs,board_num);

%--------------------------------------------------------------------------
% Remove outliers and overlapping fft frequencies (if selected)
%--------------------------------------------------------------------------
% Remove overlapping frequencies from fft
Visense_rmo = Visense(:,kp_inds);
Vpickup1_rmo = Vpickup1(:,kp_inds);
Vpickup2_rmo = Vpickup2(:,kp_inds);
Visense_snr_rmo = Visense_snr(:,kp_inds);
Vpickup1_snr_rmo = Vpickup1_snr(:,kp_inds);
Vpickup2_snr_rmo = Vpickup2_snr(:,kp_inds);
f_rmo = freqs(kp_inds);
if rm_outliers
    % Find outliers
    [Visense_rmo, rmIdx1] = rmoutliers(Visense_rmo','percentiles',prange);
    [Vpickup1_rmo, rmIdx2] = rmoutliers(Vpickup1_rmo','percentiles',prange);
    [Vpickup2_rmo, rmIdx3] = rmoutliers(Vpickup2_rmo','percentiles',prange);

end


%--------------------------------------------------------------------------
% Save
%--------------------------------------------------------------------------
save(save_path);
disp(['All workspace variables saved to ' save_path])
end

