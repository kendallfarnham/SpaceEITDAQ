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
function main_gui_combine_plot_variables(eit_data_struct,save_path,board_num)
%--------------------------------------------------------------------------
% Check inputs
%--------------------------------------------------------------------------
freqs = eit_data_struct(1).f;
%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
% Load AFE circuit parameters
[afe_params] = get_circuit_parameters(board_num);
Rsense = afe_params.Rsense;         % sense resistor value
%--------------------------------------------------------------------------
% Extract/combine voltages, currents, loads
for k = 1:length(eit_data_struct)
    if exist('eit_data_struct(k).R','var')
        R(k,:,:) = squeeze(eit_data_struct(k).R);
        X(k,:,:) = squeeze(eit_data_struct(k).X);
    elseif exist('eit_data_struct(k).Z','var')
        Z(k,:,:) = squeeze(eit_data_struct(k).Z);
    else
        Z(k,:,:) = squeeze(pol2cart(eit_data_struct(k).Zphase,eit_data_struct(k).Zmag));
    end
    Zmag(k,:,:) = squeeze(eit_data_struct(k).Zmag);
    Zphase(k,:,:) = squeeze(eit_data_struct(k).Zphase);
    Vmeas(k,:,:) = squeeze(eit_data_struct(k).Vmeas);
    Visense(k,:,:) = squeeze(eit_data_struct(k).Visense);
    Vpickup1(k,:,:) = squeeze(eit_data_struct(k).Vpickup1);
    Vpickup2(k,:,:) = squeeze(eit_data_struct(k).Vpickup2);
    Isense(k,:,:) = squeeze(eit_data_struct(k).Isense);
end
%--------------------------------------------------------------------------
if exist('Z','var')
    R = real(Z);
    X = imag(Z);
else
    Z = pol2cart(Zphase,Zmag);
end
%--------------------------------------------------------------------------
Vload = Vpickup1 - Vpickup2;
Rload = Vload./Isense;          % estimated load impedance
%--------------------------------------------------------------------------
% Calibration - new
[Rload_cal1] = calibrate_rpickup(Vpickup1,Isense,freqs,board_num);
[Rload_cal2] = calibrate_rpickup(Vpickup2,Isense,freqs,board_num);
% Rload_cal = [Rload_cal1; Rload_cal2];
[Rload_cal, Rl_cf, Vpu_Vdivide_gain] = calibrate_rload(R,freqs,board_num);
%--------------------------------------------------------------------------
if ~exist('eit_data_struct(k).pltvars','var')
    disp('No pltvars struct, existing main_gui_combine_plot_variables.m')
else
    %--------------------------------------------------------------------------
    % Extract/combine voltages, currents, loads using plot variables
    for k = 1:length(eit_data_struct)
        plt_vars_struct = eit_data_struct(k).pltvars;
        %--------------------------------------------------------------------------
        % Extract load impedance, calculate snar and precision
        rload = (plt_vars_struct.vload_vpp)./(plt_vars_struct.vpp_i/Rsense);
        Rload_precision(k,:) = std(rload); % standard deviation
        Rload_snr(k,:) = 20*log10(mean(rload)./std(rload));

        %
        % Visense(k,:,:) = plt_vars_struct.vpp_i;
        % Vpickup1(k,:,:) = plt_vars_struct.vpp_v1;
        % Vpickup2(k,:,:) = plt_vars_struct.vpp_v2;
        % Vload(k,:,:) = plt_vars_struct.vload_vpp;
        Visense_thd(k,:,:) = plt_vars_struct.thd_i;
        Vpickup1_thd(k,:,:) = plt_vars_struct.thd_v1;
        Vpickup2_thd(k,:,:) = plt_vars_struct.thd_v2;
        Rload_cal0(k,:,:) = plt_vars_struct.rload_cal;
        Rload_est(k,:,:) = plt_vars_struct.rload;

        %--------------------------------------------------------------------------
        % Extract voltage SNR
        Visense_snr(k,:) = plt_vars_struct.snr_i;
        Vpickup1_snr(k,:) = plt_vars_struct.snr_v1;
        Vpickup2_snr(k,:) = plt_vars_struct.snr_v2;
        vpp = plt_vars_struct.vload_vpp;
        Vload_snr(k,:) = 20*log10(mean(vpp)./std(vpp));
        Vload_precision(k,:) = std(vpp); % standard deviation


        %--------------------------------------------------------------------------
        % Extract SNRs for all demod data from FPGA
        if numel(plt_vars_struct.avg_adc_data.snr_k1) == 3 % one dataset
            Visense_snr_k1(k,:) = plt_vars_struct.avg_adc_data.snr_k1(1);
            Vpickup1_snr_k1(k,:) = plt_vars_struct.avg_adc_data.snr_k1(2);
            Vpickup2_snr_k1(k,:) = plt_vars_struct.avg_adc_data.snr_k1(3);
            Visense_snr_k2(k,:) = plt_vars_struct.avg_adc_data.snr_k2(1);
            Vpickup1_snr_k2(k,:) = plt_vars_struct.avg_adc_data.snr_k2(2);
            Vpickup2_snr_k2(k,:) = plt_vars_struct.avg_adc_data.snr_k2(3);
            Visense_snr_dc(k,:) = plt_vars_struct.avg_adc_data.snr_dc(1);
            Vpickup1_snr_dc(k,:) = plt_vars_struct.avg_adc_data.snr_dc(2);
            Vpickup2_snr_dc(k,:) = plt_vars_struct.avg_adc_data.snr_dc(3);
            Visense_snr_sum2(k,:) = plt_vars_struct.avg_adc_data.snr_mag2sum(1);
            Vpickup1_snr_sum2(k,:) = plt_vars_struct.avg_adc_data.snr_mag2sum(2);
            Vpickup2_snr_sum2(k,:) = plt_vars_struct.avg_adc_data.snr_mag2sum(3);

            % Extract precisions for all demod data from FPGA
            Visense_precision_k1(k,:) = plt_vars_struct.avg_adc_data.precision_k1(1);
            Vpickup1_precision_k1(k,:) = plt_vars_struct.avg_adc_data.precision_k1(2);
            Vpickup2_precision_k1(k,:) = plt_vars_struct.avg_adc_data.precision_k1(3);
            Visense_precision_k2(k,:) = plt_vars_struct.avg_adc_data.precision_k2(1);
            Vpickup1_precision_k2(k,:) = plt_vars_struct.avg_adc_data.precision_k2(2);
            Vpickup2_precision_k2(k,:) = plt_vars_struct.avg_adc_data.precision_k2(3);
            Visense_precision_dc(k,:) = plt_vars_struct.avg_adc_data.precision_dc(1);
            Vpickup1_precision_dc(k,:) = plt_vars_struct.avg_adc_data.precision_dc(2);
            Vpickup2_precision_dc(k,:) = plt_vars_struct.avg_adc_data.precision_dc(3);
            Visense_precision_sum2(k,:) = plt_vars_struct.avg_adc_data.precision_mag2sum(1);
            Vpickup1_precision_sum2(k,:) = plt_vars_struct.avg_adc_data.precision_mag2sum(2);
            Vpickup2_precision_sum2(k,:) = plt_vars_struct.avg_adc_data.precision_mag2sum(3);
        else
            Visense_snr_k1(k,:) = plt_vars_struct.avg_adc_data.snr_k1(1,:);
            Vpickup1_snr_k1(k,:) = plt_vars_struct.avg_adc_data.snr_k1(2,:);
            Vpickup2_snr_k1(k,:) = plt_vars_struct.avg_adc_data.snr_k1(3,:);
            Visense_snr_k2(k,:) = plt_vars_struct.avg_adc_data.snr_k2(1,:);
            Vpickup1_snr_k2(k,:) = plt_vars_struct.avg_adc_data.snr_k2(2,:);
            Vpickup2_snr_k2(k,:) = plt_vars_struct.avg_adc_data.snr_k2(3,:);
            Visense_snr_dc(k,:) = plt_vars_struct.avg_adc_data.snr_dc(1,:);
            Vpickup1_snr_dc(k,:) = plt_vars_struct.avg_adc_data.snr_dc(2,:);
            Vpickup2_snr_dc(k,:) = plt_vars_struct.avg_adc_data.snr_dc(3,:);
            Visense_snr_sum2(k,:) = plt_vars_struct.avg_adc_data.snr_mag2sum(1,:);
            Vpickup1_snr_sum2(k,:) = plt_vars_struct.avg_adc_data.snr_mag2sum(2,:);
            Vpickup2_snr_sum2(k,:) = plt_vars_struct.avg_adc_data.snr_mag2sum(3,:);

            % Extract precisions for all demod data from FPGA
            Visense_precision_k1(k,:) = plt_vars_struct.avg_adc_data.precision_k1(1,:);
            Vpickup1_precision_k1(k,:) = plt_vars_struct.avg_adc_data.precision_k1(2,:);
            Vpickup2_precision_k1(k,:) = plt_vars_struct.avg_adc_data.precision_k1(3,:);
            Visense_precision_k2(k,:) = plt_vars_struct.avg_adc_data.precision_k2(1,:);
            Vpickup1_precision_k2(k,:) = plt_vars_struct.avg_adc_data.precision_k2(2,:);
            Vpickup2_precision_k2(k,:) = plt_vars_struct.avg_adc_data.precision_k2(3,:);
            Visense_precision_dc(k,:) = plt_vars_struct.avg_adc_data.precision_dc(1,:);
            Vpickup1_precision_dc(k,:) = plt_vars_struct.avg_adc_data.precision_dc(2,:);
            Vpickup2_precision_dc(k,:) = plt_vars_struct.avg_adc_data.precision_dc(3,:);
            Visense_precision_sum2(k,:) = plt_vars_struct.avg_adc_data.precision_mag2sum(1,:);
            Vpickup1_precision_sum2(k,:) = plt_vars_struct.avg_adc_data.precision_mag2sum(2,:);
            Vpickup2_precision_sum2(k,:) = plt_vars_struct.avg_adc_data.precision_mag2sum(3,:);
        end
    end
end
%--------------------------------------------------------------------------
% Save
%--------------------------------------------------------------------------
save(save_path);
disp(['All workspace variables saved to ' save_path])
