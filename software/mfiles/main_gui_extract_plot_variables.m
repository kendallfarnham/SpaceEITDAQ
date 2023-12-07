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
function main_gui_extract_plot_variables(eit_data_struct,save_path,board_num, ...
    avg_datasets,rm_outliers,kp_inds,prange)
%--------------------------------------------------------------------------
% Check inputs
%--------------------------------------------------------------------------
freqs = eit_data_struct(1).freqs;
%--------------------------------------------------------------------------
% Set defaults for optional inputs
if ~exist('avg_datasets','var'); avg_datasets = 0; end  % average data per freq
if ~exist('rm_outliers','var'); rm_outliers = 0; end    % don't remove outliers
if ~exist('kp_inds','var'); kp_inds = 1:length(freqs); end % keep all frequency indices
if ~exist('prange','var'); prange = [0 1]; end % keep all data (percentile range 100%)
%--------------------------------------------------------------------------
% Load AFE circuit parameters
[afe_params] = get_circuit_parameters(board_num);
Rsense = afe_params.Rsense;         % sense resistor value
%--------------------------------------------------------------------------
% Extract voltages
for k = 1:length(eit_data_struct)
    %--------------------------------------------------------------------------
    % Extract load impedance, calculate snr and precision
    rload = (eit_data_struct(k).vload_vpp)./(eit_data_struct(k).vpp_i/Rsense);
    Rload_precision(k,:) = std(rload); % standard deviation
    Rload_snr(k,:) = 20*log10(mean(rload)./std(rload));

    %--------------------------------------------------------------------------
    % Extract voltages, currents, load
    if avg_datasets
        Visense(k,:) = mean(eit_data_struct(k).vpp_i);
        Vpickup1(k,:) = mean(eit_data_struct(k).vpp_v1);
        Vpickup2(k,:) = mean(eit_data_struct(k).vpp_v2);
        Visense_thd(k,:) = mean(eit_data_struct(k).thd_i);
        Vpickup1_thd(k,:) = mean(eit_data_struct(k).thd_v1);
        Vpickup2_thd(k,:) = mean(eit_data_struct(k).thd_v2);
        Vload(k,:) = mean(eit_data_struct(k).vload_vpp);
        Rload_cal0(k,:) = mean(eit_data_struct(k).rload_cal);
        if exist('eit_data_struct(k).rload','var')
            Rload0(k,:) = mean(eit_data_struct(k).rload);
        end
    else
        Visense(k,:,:) = eit_data_struct(k).vpp_i;
        Vpickup1(k,:,:) = eit_data_struct(k).vpp_v1;
        Vpickup2(k,:,:) = eit_data_struct(k).vpp_v2;
        Visense_thd(k,:,:) = eit_data_struct(k).thd_i;
        Vpickup1_thd(k,:,:) = eit_data_struct(k).thd_v1;
        Vpickup2_thd(k,:,:) = eit_data_struct(k).thd_v2;
        Vload(k,:,:) = eit_data_struct(k).vload_vpp;
        Rload_cal0(k,:,:) = eit_data_struct(k).rload_cal;
        if exist('eit_data_struct(k).rload','var')
            Rload0(k,:,:) = eit_data_struct(k).rload;
        end
    end

    %--------------------------------------------------------------------------
    % Extract voltage SNR
    Visense_snr(k,:) = eit_data_struct(k).snr_i;
    Vpickup1_snr(k,:) = eit_data_struct(k).snr_v1;
    Vpickup2_snr(k,:) = eit_data_struct(k).snr_v2;
    vpp = eit_data_struct(k).vload_vpp;
    Vload_snr(k,:) = 20*log10(mean(vpp)./std(vpp));
    Vload_precision(k,:) = std(vpp); % standard deviation

    %--------------------------------------------------------------------------
    % Extract SNRs for all demod data from FPGA
    if numel(eit_data_struct(k).avg_adc_data.snr_k1) == 3 % one dataset
        Visense_snr_k1(k,:) = eit_data_struct(k).avg_adc_data.snr_k1(1);
        Vpickup1_snr_k1(k,:) = eit_data_struct(k).avg_adc_data.snr_k1(2);
        Vpickup2_snr_k1(k,:) = eit_data_struct(k).avg_adc_data.snr_k1(3);
        Visense_snr_k2(k,:) = eit_data_struct(k).avg_adc_data.snr_k2(1);
        Vpickup1_snr_k2(k,:) = eit_data_struct(k).avg_adc_data.snr_k2(2);
        Vpickup2_snr_k2(k,:) = eit_data_struct(k).avg_adc_data.snr_k2(3);
        Visense_snr_dc(k,:) = eit_data_struct(k).avg_adc_data.snr_dc(1);
        Vpickup1_snr_dc(k,:) = eit_data_struct(k).avg_adc_data.snr_dc(2);
        Vpickup2_snr_dc(k,:) = eit_data_struct(k).avg_adc_data.snr_dc(3);
        Visense_snr_sum2(k,:) = eit_data_struct(k).avg_adc_data.snr_mag2sum(1);
        Vpickup1_snr_sum2(k,:) = eit_data_struct(k).avg_adc_data.snr_mag2sum(2);
        Vpickup2_snr_sum2(k,:) = eit_data_struct(k).avg_adc_data.snr_mag2sum(3);

        % Extract precisions for all demod data from FPGA
        Visense_precision_k1(k,:) = eit_data_struct(k).avg_adc_data.precision_k1(1);
        Vpickup1_precision_k1(k,:) = eit_data_struct(k).avg_adc_data.precision_k1(2);
        Vpickup2_precision_k1(k,:) = eit_data_struct(k).avg_adc_data.precision_k1(3);
        Visense_precision_k2(k,:) = eit_data_struct(k).avg_adc_data.precision_k2(1);
        Vpickup1_precision_k2(k,:) = eit_data_struct(k).avg_adc_data.precision_k2(2);
        Vpickup2_precision_k2(k,:) = eit_data_struct(k).avg_adc_data.precision_k2(3);
        Visense_precision_dc(k,:) = eit_data_struct(k).avg_adc_data.precision_dc(1);
        Vpickup1_precision_dc(k,:) = eit_data_struct(k).avg_adc_data.precision_dc(2);
        Vpickup2_precision_dc(k,:) = eit_data_struct(k).avg_adc_data.precision_dc(3);
        Visense_precision_sum2(k,:) = eit_data_struct(k).avg_adc_data.precision_mag2sum(1);
        Vpickup1_precision_sum2(k,:) = eit_data_struct(k).avg_adc_data.precision_mag2sum(2);
        Vpickup2_precision_sum2(k,:) = eit_data_struct(k).avg_adc_data.precision_mag2sum(3);
    else
        Visense_snr_k1(k,:) = eit_data_struct(k).avg_adc_data.snr_k1(1,:);
        Vpickup1_snr_k1(k,:) = eit_data_struct(k).avg_adc_data.snr_k1(2,:);
        Vpickup2_snr_k1(k,:) = eit_data_struct(k).avg_adc_data.snr_k1(3,:);
        Visense_snr_k2(k,:) = eit_data_struct(k).avg_adc_data.snr_k2(1,:);
        Vpickup1_snr_k2(k,:) = eit_data_struct(k).avg_adc_data.snr_k2(2,:);
        Vpickup2_snr_k2(k,:) = eit_data_struct(k).avg_adc_data.snr_k2(3,:);
        Visense_snr_dc(k,:) = eit_data_struct(k).avg_adc_data.snr_dc(1,:);
        Vpickup1_snr_dc(k,:) = eit_data_struct(k).avg_adc_data.snr_dc(2,:);
        Vpickup2_snr_dc(k,:) = eit_data_struct(k).avg_adc_data.snr_dc(3,:);
        Visense_snr_sum2(k,:) = eit_data_struct(k).avg_adc_data.snr_mag2sum(1,:);
        Vpickup1_snr_sum2(k,:) = eit_data_struct(k).avg_adc_data.snr_mag2sum(2,:);
        Vpickup2_snr_sum2(k,:) = eit_data_struct(k).avg_adc_data.snr_mag2sum(3,:);

        % Extract precisions for all demod data from FPGA
        Visense_precision_k1(k,:) = eit_data_struct(k).avg_adc_data.precision_k1(1,:);
        Vpickup1_precision_k1(k,:) = eit_data_struct(k).avg_adc_data.precision_k1(2,:);
        Vpickup2_precision_k1(k,:) = eit_data_struct(k).avg_adc_data.precision_k1(3,:);
        Visense_precision_k2(k,:) = eit_data_struct(k).avg_adc_data.precision_k2(1,:);
        Vpickup1_precision_k2(k,:) = eit_data_struct(k).avg_adc_data.precision_k2(2,:);
        Vpickup2_precision_k2(k,:) = eit_data_struct(k).avg_adc_data.precision_k2(3,:);
        Visense_precision_dc(k,:) = eit_data_struct(k).avg_adc_data.precision_dc(1,:);
        Vpickup1_precision_dc(k,:) = eit_data_struct(k).avg_adc_data.precision_dc(2,:);
        Vpickup2_precision_dc(k,:) = eit_data_struct(k).avg_adc_data.precision_dc(3,:);
        Visense_precision_sum2(k,:) = eit_data_struct(k).avg_adc_data.precision_mag2sum(1,:);
        Vpickup1_precision_sum2(k,:) = eit_data_struct(k).avg_adc_data.precision_mag2sum(2,:);
        Vpickup2_precision_sum2(k,:) = eit_data_struct(k).avg_adc_data.precision_mag2sum(3,:);
    end
    %--------------------------------------------------------------------------
    % Calculate measured current (Isense) and load current (V1-V2)
    Isense = Visense/Rsense;
    Vload = Vpickup1 - Vpickup2;
    if exist('eit_data_struct(k).rload','var')
        Rload_est = Rload0;             % save from struct
    end
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
    if rm_outliers
        Visense_rmo = Visense(:,kp_inds);
        Vpickup1_rmo = Vpickup1(:,kp_inds);
        Vpickup2_rmo = Vpickup2(:,kp_inds);
        f_rmo = freqs(kp_inds);
        if size(Visense_snr,2) == 1
            kp_inds = 1;
        end
        Visense_snr_rmo = Visense_snr(:,kp_inds);
        Vpickup1_snr_rmo = Vpickup1_snr(:,kp_inds);
        Vpickup2_snr_rmo = Vpickup2_snr(:,kp_inds);

        % Find outliers
        [Visense_rmo, rmIdx1] = rmoutliers(Visense_rmo','percentiles',prange);
        [Vpickup1_rmo, rmIdx2] = rmoutliers(Vpickup1_rmo','percentiles',prange);
        [Vpickup2_rmo, rmIdx3] = rmoutliers(Vpickup2_rmo','percentiles',prange);

    end

end
%--------------------------------------------------------------------------
% Save
%--------------------------------------------------------------------------
save(save_path);
disp(['All workspace variables saved to ' save_path])
end

