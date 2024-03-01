%--------------------------------------------------------------------------
% Plot DAQ performance - thesis figures
%--------------------------------------------------------------------------
close all
clear all
addpath ../mfiles % path to extraction functions

%--------------------------------------------------------------------------
% Plots
%--------------------------------------------------------------------------
% Benchtop setup: a single set of mux channels (no switching) in tetrapolar
%       config with 100 Ohm contact resistors. Used on ARMI report 9/2023
%   Variables: Rloads 10 to 10k, freqs 109 Hz to 3.1 MHz
%   Figures: 3dB bandwidth, SNR, THD, precision
%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
% dataset_type = 1;   % no mux switching, tetra config, Rload = (V1-V2)/Isense
dataset_type = 3;   % 32 channels attached to load, one vs+/vs- pair, Rload = Vpu/Isense
%--------------------------------------------------------------------------
reextract_plot_variables = 0;
dpath = 'mat/';  % folder with data
if dataset_type == 1 
    wkspc_fname = 'data_2023_09_25_workspace_pltvars.mat';
elseif dataset_type == 3
    wkspc_fname = 'data_2023_11_08_workspace_pltvars.mat';
end
%--------------------------------------------------------------------------
% Select plots to show
plot_3dB = 0;               % plot frequency sweep with 3db point marked
plot_snr = 0;               % plot data and snr of impedance, current, and voltage
plot_current = 0;           % plot sensed and measured current
plot_precision = 0;         % plot amp, snr, precision of voltages/load/current
plot_rload_adjusted = 1;    % plot adjusted Rload (calibrated impedance)
plot_rload_cal_variations = 1;    % plot variations of calibrated Rload
plot_rload_precision = 0;   % plot impedance precision and snr
plot_amp_snr = 0;           % plot amplitude/snr/thd vs freq
plot_rm_overlap = 0;        % plot data with overlapping freqs removed
plot_mag_fft = 0;           % plot mag of fft data
plot_snr_fft = 0;           % plot snr of fft data
plot_precision_fft = 0;     % plot precision of fft data
plot_mean_std = 0;          % plot mean data with shaded std dev

%--------------------------------------------------------------------------
% Load workspace variables
%--------------------------------------------------------------------------
if ~isfile([dpath wkspc_fname]) % Use UI to select datasets
    [wkspc_fname,dpath] = uigetfile([dpath '*.mat'], ...
        'Select workspace or extracted data for figure','MultiSelect','on');
end
RLs = [10,50,100,200,300,500,1e3,2e3,3e3,5e3,10e3]';
%%
%--------------------------------------------------------------------------
% Extract or load the plotting data
%--------------------------------------------------------------------------
% extract_plot_variables(folder_data,workspace_path,board_num,
%       avg_datasets,rm_outliers,kp_inds,prange)
workspace_path = [dpath extractBefore(wkspc_fname,'.') '_pltvars.mat'];
if dataset_type == 1
    board_num = 2;
else
    board_num = 3;
end
if reextract_plot_variables
    if dataset_type == 1
        load([dpath wkspc_fname],'folder_data','RLs')

        %--------------------------------------------------------------------------
        % Sort by Rload
        for k = 1:length(folder_data)
            RLs(k,1) = folder_data(k).Rload;
        end
        [RLs,sorti] = sort(RLs);
        folder_data = folder_data(sorti);

        avg_datasets = 1;
        rm_outliers = 0;
        % main_gui_extract_plot_variables(folder_data,workspace_path,board_num,avg_datasets)
        extract_plot_variables(folder_data,workspace_path,board_num, ...
            avg_datasets,rm_outliers)
    elseif dataset_type == 3
        load([dpath wkspc_fname],'eit_data_struct')
        main_gui_combine_plot_variables(eit_data_struct,workspace_path,board_num)
    else
        load([dpath wkspc_fname],'eit_data_struct','plt_var_struct')
        if ~exist('plt_var_struct','var')
            main_gui_combine_plot_variables(eit_data_struct,workspace_path,board_num)
        else
            main_gui_extract_plot_variables(plt_var_struct,workspace_path,board_num,0);
        end
    end
    load(workspace_path)
    disp(['Loaded data from ' dpath wkspc_fname])
    disp(['Plot variables extracted and saved to ' workspace_path])

else
    save('tmp.mat');            % save current workspace variables
    load([dpath wkspc_fname]);  % load entire workspace
    load('tmp.mat');            % reload this script's variables
    disp(['Loaded workspace variables from ' dpath wkspc_fname])
end
%--------------------------------------------------------------------------
% Plots
%--------------------------------------------------------------------------
colororder("gem12")
%--------------------------------------------------------------------------
precision_ylims = [0 3];
snr_ylims = [20 100];
%%
%--------------------------------------------------------------------------
% Plot frequency sweep with 3dB points marked
%--------------------------------------------------------------------------
if plot_3dB
    clearvars st_3dB
    ylbl_opts = {'','Vpp','mA','\Omega'};
    fig_xlbl = 'Frequency (Hz)';    % figure xlabel
    %--------------------------------------------------------------------------
    vars2plot = {'Isense*1000','Vload','Rload'};
    plt_titles = {'Sensed Current (Isense)','Sensed Voltage (Vload)','Rload = Vload/Isense'};
    ylbl_sel = [3 2 4];   % ylabels on tiles
    fig_ylbl = '';         % figure ylabel
    %--------------------------------------------------------------------------
    figure;
    t = tiledlayout('horizontal','TileSpacing','compact','Padding','compact');
    for n = 1:length(vars2plot)
        eval(['pltvar = ' vars2plot{n} ';']);
        nexttile
        semilogx(freqs,pltvar); grid on; hold on
        title(plt_titles{n}), ylabel(ylbl_opts{ylbl_sel(n)})
        for k = 1:size(pltvar,1)   % Get 3dB points and plot
            [i_3dB st_3dB(k,:,n)] = get_3dB_points(pltvar(k,:),2);
            semilogx(freqs(i_3dB),pltvar(k,i_3dB),'k*')
        end
    end

    % Plot Legend
    lgd_str = [num2str(RLs); '3dB  '];
    legend(lgd_str,'Location','northeastoutside');
    xlabel(t,fig_xlbl); ylabel(t,fig_ylbl);
    sgtitle('Frequency Response')

end
%%
%--------------------------------------------------------------------------
% Plot frequency sweep and snr of impedance, current, and voltage
%--------------------------------------------------------------------------
if plot_snr
    %--------------------------------------------------------------------------
    % Plot estimated Rload, current, voltage freq response and SNRs
    %--------------------------------------------------------------------------
    figure; t = tiledlayout(2,3,'TileSpacing','tight');
    nexttile; semilogx(freqs,Rload_precision)
    title('Impedance Precision (\Omega)'), ylabel('Ohms (\Omega)'), grid on
    nexttile; semilogx(freqs,Isense*1000)
    title('Sensed Current (mA)'), ylabel('mA'), grid on
    nexttile; semilogx(freqs,Vload)
    title('Sensed Voltage (V1-V2)'), ylabel('Vpp'), grid on

    lgd = legend(num2str(RLs),'Location','northeastoutside'); title(lgd,'RLoad (\Omega)');

    %     % Plot Means
    % nexttile; semilogx(freqs,Rload),
    % title('Measured Resistance'), ylabel('Ohms (\Omega)'), grid on
    % nexttile; semilogx(freqs,Visense),
    % title('Current Sense (Visense)'), ylabel('Vpp'), grid on
    % nexttile; semilogx(freqs,Vload)
    % title('Sensed Voltage (V1-V2)'), ylabel('Vpp'), grid on

    % Plot SNRs
    nexttile; semilogx(freqs,Rload_snr), ylim(snr_ylims)
    title('Impedance SNR'), ylabel('dB'), grid on
    nexttile; semilogx(freqs,Visense_snr), ylim(snr_ylims)
    title('Sensed Current SNR'), grid on
    nexttile; semilogx(freqs,Vpickup1_snr), ylim(snr_ylims)
    title('Sensed Voltage SNR'), grid on

    title(t,'Frequency Response: Sensed Load Impedance, Current, and Voltage')
    xlabel(t,'Frequency (Hz)')
end
%%
if plot_precision
    %--------------------------------------------------------------------------
    % Plot ADC voltages and SNR
    %--------------------------------------------------------------------------
    figure;
    t = tiledlayout('flow','TileSpacing','compact');
    % Plot voltages
    %---------------------
    nexttile;
    semilogx(freqs,Visense); hold on; grid on, title('Visense')
    ylabel('Voltage (Vpp)')
    for k = 1:size(Visense,1)   % Get 3dB points and plot
        [i_3dB] = get_3dB_points(Visense(k,:));
        semilogx(freqs(i_3dB),Visense(k,i_3dB),'k*')
    end
    %---------------------
    nexttile;
    semilogx(freqs,Vload); hold on; grid on, title('Vload = V1 - V2')
    ylabel('Voltage (Vpp)')
    for k = 1:size(Vload,1)   % Get 3dB points and plot
        [i_3dB] = get_3dB_points(Vload(k,:));
        semilogx(freqs(i_3dB),Vload(k,i_3dB),'k*')
    end
    %---------------------
    nexttile;
    semilogx(freqs,Vpickup1); hold on; grid on, title('Vpickup Ch 1 (V1)')
    for k = 1:size(Vpickup1,1)   % Get 3dB points and plot
        [i_3dB] = get_3dB_points(Vpickup1(k,:));
        semilogx(freqs(i_3dB),Vpickup1(k,i_3dB),'k*')
    end
    %---------------------
    nexttile;
    semilogx(freqs,Vpickup2); hold on; grid on, title('Vpickup Ch 2 (V2)')
    for k = 1:size(Vpickup2,1)   % Get 3dB points and plot
        [i_3dB] = get_3dB_points(Vpickup2(k,:));
        semilogx(freqs(i_3dB),Vpickup2(k,i_3dB),'k*')
    end
    %---------------------
    lgd = legend(num2str(RLs),'Location','northeastoutside'); title(lgd,'RLoad (\Omega)');
    %---------------------
    % Plot SNRs
    nexttile; semilogx(freqs,Visense_snr), ylim(snr_ylims)
    ylabel('SNR (dB)'), grid on
    nexttile; semilogx(freqs,Vload_snr), ylim(snr_ylims), grid on
    nexttile; semilogx(freqs,Vpickup1_snr), ylim(snr_ylims), grid on
    nexttile; semilogx(freqs,Vpickup2_snr), ylim(snr_ylims), grid on
    % title(t,'Frequency Response: ADC Voltages and SNR')
    %---------------------
    % Plot Precision
    nexttile; semilogx(freqs,Visense_precision_k2), ylim(precision_ylims)
    ylabel('Precision (\sigma)'), grid on
    nexttile; semilogx(freqs,Vload_precision), ylim(precision_ylims), grid on
    nexttile; semilogx(freqs,Vpickup1_precision_k2), ylim(precision_ylims), grid on
    nexttile; semilogx(freqs,Vpickup2_precision_k2), ylim(precision_ylims), grid on
    title(t,'Frequency Response: Voltage Amplitude, SNR, and Precision')

    %---------------------
    xlabel(t,'Frequency (Hz)')

end

%%
%--------------------------------------------------------------------------
% Plot current
if plot_current

    figure;
    semilogx(freqs,Isense*1000); grid on; hold on
    title('Sensed Current: Isense = Visense/Rsense')
    xlabel('Frequency (Hz)'), ylabel('Current (mA)')

    % plot 3db
    for k = 1:size(Isense,1)   % Get 3dB points and plot
        [i_3dB st_3dB(k,:,n)] = get_3dB_points(Isense(k,:));
        semilogx(freqs(i_3dB),Isense(k,i_3dB)*1000,'k*')
    end

    % Plot Legend
    lgd_str = [num2str(RLs); '3dB  '];
    legend(lgd_str,'Location','northeastoutside');
end
%%
%--------------------------------------------------------------------------
% Plot impedance precision and snr
%--------------------------------------------------------------------------

if plot_rload_adjusted

    %--------------------------------------------------------------------------
    % Set calibrated variable
    if dataset_type == 1
        Rload_plot = Rload;
        % Rload_cal = calibrate_rload(Vload./Isense,freqs,board_num);
        Rload_cal = calibrate_rload_freqsweep(Vload./Isense,freqs,board_num,0,1);
    elseif dataset_type == 3
        Rload_plot = R;
        Vpickup_multi = cat(2,Vpickup1,Vpickup2);
        Isense_multi = cat(2,Isense,Isense);
        Rload_cal = calibrate_rpickup_freqsweep(Vpickup_multi,Isense_multi,freqs,board_num,1);
    end
    %--------------------------------------------------------------------------
    % Setup plot colors
    figure;
    colororder("gem12");
    C = colororder;
    if size(C,1) > size(Rload_plot,1)
        newcolors = C(1:size(Rload_plot,1),:);
        colororder(newcolors)
    end
    RLs = [10,50,100,200,300,500,1e3,2e3,3e3,5e3,10e3]'; % get rloads on resistor board
    Rl_actual = repmat(RLs,[1 length(freqs)]);
    t = tiledlayout('horizontal','TileSpacing','compact','Padding','compact');
        %--------------------------------------------------------------------------
    if ndims(Rload_plot) > 2 % loop
        nexttile
        for chi = 1:size(Rload_plot,2)
            loglog(freqs,squeeze(Rload_plot(:,chi,:))); hold on
        end
        grid on; title('Rload = Vload \div Isense')
        loglog(freqs,Rl_actual,'--')

        nexttile
        for chi = 1:size(Rload_cal,2)
            loglog(freqs,squeeze(Rload_cal(:,chi,:))); hold on
        end
        grid on; title('Rload = Vload \div Isense')
        loglog(freqs,Rl_actual,'--')
    else
        nexttile
        loglog(freqs,Rload_plot); grid on; title('Rload = Vload \div Isense')
        hold on; loglog(freqs,Rl_actual,'--')
        nexttile
        loglog(freqs,Rload_cal); grid on; title('Adjusted Rload ')
        hold on; loglog(freqs,Rl_actual,'--')

    end
    %------------------------
    lgd = legend(cellstr(num2str(RLs)),'Location','northeastoutside'); title(lgd,'RLoad (\Omega)')
    title(t,'Calibrating Measured Load Resistance (Rload = Vload/Isense)')
    xlabel(t,'Frequency (Hz)')
    %---------------------------------------
end
%%
%--------------------------------------------------------------------------
% Plot variations of calibrated Rload
%--------------------------------------------------------------------------
if plot_rload_cal_variations
    %--------------------------------------------------------------------------
    % Get calibration variations

    nchs = 1;
    [rload_cal_01, ~, ~] = calibrate_rload(Vpickup1./Isense,freqs,board_num);
    [rload_cal_02, ~, ~] = calibrate_rload(Vpickup2./Isense,freqs,board_num);
    [rload_cal_03] = calibrate_rpickup(Vpickup1,Isense,freqs,board_num,nchs);
    [rload_cal_04] = calibrate_rpickup(Vpickup2,Isense,freqs,board_num,nchs);
        if exist('Zmag','var')
        [rload_cal_05] = calibrate_rload(Zmag,freqs,board_num);
        [rload_cal_06] = calibrate_rload(R,freqs,board_num);
    end
    if dataset_type == 1
        Rload_plot = Rload;
         Rload_cal = calibrate_rload(Vload./Isense,freqs,board_num);
         rload_cal1 = rload_cal_01 - rload_cal_02;
         rload_cal2 = rload_cal_03 - rload_cal_04;
    elseif dataset_type == 3
        Rload_plot = R;
        rload_cal1 = calibrate_rpickup(Vpickup1,Isense,freqs,board_num,nchs);
        rload_cal2 = calibrate_rpickup(Vpickup2,Isense,freqs,board_num,nchs);
    end
    nvals = 2;
    %--------------------------------------------------------------------------
    % Sort by Rload
    if dataset_type == 2 ||  dataset_type == 3
        Rsort = Vpickup1./Isense;
    else
        Rsort = Rload_plot;
    end
    %%
    mdpt = round(size(Rload_plot,2)/2);
    for k = 1:size(Rsort,1)
        RL(k,1) = Rsort(k,mdpt);
    end
    [RL,rl_sorti] = sort(RL); % get sorted indices

    %---------------------------------------
    % Setup plot colors
    figure;
    t = tiledlayout('flow','TileSpacing','compact','Padding','compact');
    colororder("gem12");
    C = colororder;
    if size(C,1) > size(Rload_plot,1)
        newcolors = C(1:size(Rload_plot,1),:);
        colororder(newcolors)
    end
    RLs = [10,50,100,200,300,500,1e3,2e3,3e3,5e3,10e3]'; % get rloads on resistor board
    Rl_actual = repmat(RLs,[1 length(freqs)]);

    %--------------------------------------------------------------------------

    if ndims(Rload_plot) > 2 % loop
        nexttile
        for chi = 1:size(Rload_plot,2)
            loglog(freqs,squeeze(abs(R(:,chi,:)))); hold on
        end
        grid on; title('Rload = Vload \div Isense')
        loglog(freqs,Rl_actual,'--')

        nexttile
        for chi = 1:size(Rload_cal,2)
            loglog(freqs,squeeze(abs(Rload_cal(:,chi,:)))); hold on
        end
        grid on; title('Calibrated Rload')
        loglog(freqs,Rl_actual,'--')

        for n = 1:nvals
            nexttile
            % Load rload, sort the dataset
            eval(['plty = rload_cal' num2str(n) ';']);
            plty = plty(rl_sorti,:,:);   % sort by load
            for chi = 1:size(plty,2)
                loglog(freqs,squeeze(abs(plty(:,chi,:)))); hold on
            end
            grid on; title(['Rcalibrated ' num2str(n)])
            loglog(freqs,Rl_actual,'--')
        end
    else
        %---------------------------------------
        nexttile
        loglog(freqs,abs(Rload_plot)); title('Rload = Vload \div Isense')
        hold on; loglog(freqs,Rl_actual,'--');
        nexttile
        loglog(freqs,Rload_cal); title('Calibrated Rload')
        hold on; loglog(freqs,Rl_actual,'--');

        for n = 1:nvals
            % Load rload, sort the dataset
            eval(['plty = rload_cal' num2str(n) ';']);
            plty = plty(rl_sorti,:);   % sort by load
            nexttile
            loglog(freqs,abs(plty)); grid on; title(['Rcalibrated ' num2str(n)])
            hold on; loglog(freqs,Rl_actual,'--')
        end
    end

    %------------------------
    lgd = legend(cellstr(num2str(RLs)),'Location','northeastoutside'); title(lgd,'RLoad (\Omega)')
    title(t,'Calibrating Measured Load Resistance (Rload = Vload/Isense)')
    xlabel(t,'Frequency (Hz)')
end
%%
%--------------------------------------------------------------------------
% Plot impedance precision and snr
%--------------------------------------------------------------------------
if plot_rload_precision

    % Plot impedance precision vs freq
    x = [100 1e7];
    figure;
    t = tiledlayout('horizontal','TileSpacing','compact','Padding','compact');
    nexttile
    semilogx(freqs,Rload_plot); hold on; title('Uncalibrated Rload')
    ylabel('Resistance (\Omega)'), grid on
    nexttile
    semilogx(freqs,Rload_precision); hold on; title('Standard Deviation')
    semilogx(x,ones(size(x)),'k--','LineWidth',2) % 1 Ohm target
    ylabel('\sigma (\Omega)'), grid on
    nexttile
    semilogx(freqs,Rload_snr); ylim(snr_ylims); grid on; hold on; title('SNR')
    semilogx(x,80*ones(size(x)),'k--','LineWidth',2) % 80 dB target
    ylabel('SNR (dB)')
    title(t,'Impedance Precision and SNR: Z = Vload/Isense')
    xlabel(t,'Frequency (Hz)')
    lgd_str = cellstr(num2str(RLs));
    lgd_str{end+1} = 'Target';
    lgd = legend(lgd_str,'Location','northeastoutside'); title(lgd,'RLoad (\Omega)');

    %--------------------------------------------------------------------------
    figure;
    t = tiledlayout('flow','TileSpacing','compact','Padding','compact');
    nexttile
    semilogx(freqs,Rload_precision); hold on
    semilogx(x,ones(size(x)),'k--','LineWidth',2) % 1 Ohm target
    ylabel(t,'\sigma (\Omega)'), xlabel(t,'Frequency (Hz)'), grid on
    title(t,'Impedance Precision: Z = Vload/Isense')
    lgd_str = cellstr(num2str(RLs));
    lgd_str{end+1} = '1\Omega Target';
    lgd = legend(lgd_str,'Location','northeastoutside'); title(lgd,'RLoad (\Omega)');
end

%%
%--------------------------------------------------------------------------
% Demodulation plots (Extracted FFT data from FPGA)
%--------------------------------------------------------------------------
% Plot extracted amplitude/thd/snr data
%--------------------------------------------------------------------------
if plot_amp_snr
    figure;
    subplot 331; semilogx(freqs,Visense), title('Isense ADC'); grid on, hold on
    ylabel('Amplitude (V)');
    subplot 332; semilogx(freqs,Vpickup1), title('Vpickup 1 ADC'); grid on, hold on
    subplot 333; semilogx(freqs,Vpickup2), title('Vpickup 2 ADC'); grid on, hold on
    legend(num2str(RLs),'Location','northeastoutside');

    subplot 334; semilogx(freqs,Visense_snr), grid on, hold on, xlabel('Frequency (Hz)')
    ylabel('SNR (dB)'); ylim(snr_ylims)
    subplot 335; semilogx(freqs,Vpickup1_snr), grid on, hold on, xlabel('Frequency (Hz)'), ylim(snr_ylims)
    subplot 336; semilogx(freqs,Vpickup2_snr), grid on, hold on, xlabel('Frequency (Hz)'), ylim(snr_ylims)

    subplot 337; semilogx(RLs,Visense_thd), grid on, hold on
    ylabel('THD'), xlabel('Rload (Ohms)')
    subplot 338; semilogx(RLs,Vpickup1_thd), grid on, xlabel('Rload (Ohms)'), hold on
    subplot 339; semilogx(RLs,Vpickup2_thd), grid on, xlabel('Rload (Ohms)'), hold on

    sgtitle(['Amplitude/SNR/THD, ' num2str(nsets) ' datasets'])

    figure;
    subplot 231; semilogx(freqs,Visense), title('Isense ADC'); grid on, hold on
    ylabel('Amplitude (V)');
    subplot 232; semilogx(freqs,Vpickup1), title('Vpickup 1 ADC'); grid on, hold on
    subplot 233; semilogx(freqs,Vpickup2), title('Vpickup 2 ADC'); grid on, hold on

    subplot 234; semilogx(freqs,Visense_snr), grid on, hold on, xlabel('Frequency (Hz)')
    ylabel('SNR (dB)'); ylim(snr_ylims)
    subplot 235; semilogx(freqs,Vpickup1_snr), grid on, hold on, xlabel('Frequency (Hz)'), ylim(snr_ylims)
    subplot 236; semilogx(freqs,Vpickup2_snr), grid on, hold on, xlabel('Frequency (Hz)'), ylim(snr_ylims)

end
%%
%--------------------------------------------------------------------------
% Plot extracted snr data
%--------------------------------------------------------------------------
if plot_mag_fft
    %------------------------
    figure; t = tiledlayout(3,4,'TileSpacing','tight');
    % Isense
    nexttile
    semilogx(freqs,Visense_mean_k1); ylabel('Isense'); title('FFT bin k'); grid on
    nexttile
    semilogx(freqs,Visense_mean_k2); title('FFT bin N-k'); grid on
    nexttile
    semilogx(freqs,Visense_mean_dc); title('FFT bin 0 (DC)'); grid on
    nexttile
    semilogx(freqs,Visense_mean_sum2); title('Sum(|F|^2)'); grid on
    legend(num2str(RLs),'Location','northeastoutside')

    % Vpickup Ch 1
    nexttile
    semilogx(freqs,Vpickup1_mean_k1); ylabel('Vpickup Ch 1'); grid on
    nexttile
    semilogx(freqs,Vpickup1_mean_k2); grid on
    nexttile
    semilogx(freqs,Vpickup1_mean_dc); grid on
    nexttile
    semilogx(freqs,Vpickup1_mean_sum2); grid on

    % Vpickup Ch 2
    nexttile
    semilogx(freqs,Vpickup2_mean_k1); ylabel('Vpickup Ch 2'); grid on
    nexttile
    semilogx(freqs,Vpickup2_mean_k2);  grid on
    nexttile
    semilogx(freqs,Vpickup2_mean_dc);  grid on
    nexttile
    semilogx(freqs,Vpickup2_mean_sum2);  grid on

    xlabel(t,'Frequency (Hz)'); ylabel(t,'SNR (dB)');
    title(t,'SNR of Demodulated ADC Data')


end
%%
%--------------------------------------------------------------------------
% Plot extracted snr data
%--------------------------------------------------------------------------
if plot_snr_fft
    %------------------------
    figure; t = tiledlayout(3,4,'TileSpacing','tight');
    % Isense
    nexttile
    semilogx(freqs,Visense_snr_k1); ylabel('Isense'); title('FFT bin k'); grid on; ylim(snr_ylims)
    nexttile
    semilogx(freqs,Visense_snr_k2); title('FFT bin N-k'); grid on; ylim(snr_ylims)
    nexttile
    semilogx(freqs,Visense_snr_dc); title('FFT bin 0 (DC)'); grid on; ylim(snr_ylims)
    nexttile
    semilogx(freqs,Visense_snr_sum2); title('Sum(|F|^2)'); grid on; ylim(snr_ylims)
    legend(num2str(RLs),'Location','northeastoutside')

    % Vpickup Ch 1
    nexttile
    semilogx(freqs,Vpickup1_snr_k1); ylabel('Vpickup Ch 1'); grid on; ylim(snr_ylims)
    nexttile
    semilogx(freqs,Vpickup1_snr_k2); grid on; ylim(snr_ylims)
    nexttile
    semilogx(freqs,Vpickup1_snr_dc); grid on; ylim(snr_ylims)
    nexttile
    semilogx(freqs,Vpickup1_snr_sum2); grid on; ylim(snr_ylims)

    % Vpickup Ch 2
    nexttile
    semilogx(freqs,Vpickup2_snr_k1); ylabel('Vpickup Ch 2'); grid on; ylim(snr_ylims)
    nexttile
    semilogx(freqs,Vpickup2_snr_k2);  grid on; ylim(snr_ylims)
    nexttile
    semilogx(freqs,Vpickup2_snr_dc);  grid on; ylim(snr_ylims)
    nexttile
    semilogx(freqs,Vpickup2_snr_sum2);  grid on; ylim(snr_ylims)

    xlabel(t,'Frequency (Hz)'); ylabel(t,'SNR (dB)');
    title(t,'SNR of Demodulated ADC Data')


end
%%
%--------------------------------------------------------------------------
% Plot extracted precision data
%--------------------------------------------------------------------------
if plot_precision_fft
    %------------------------
    figure; t = tiledlayout(3,4,'TileSpacing','tight');
    % Isense
    nexttile
    semilogx(freqs,Visense_precision_k1); ylabel('Isense'); title('FFT bin k'); grid on
    nexttile
    semilogx(freqs,Visense_precision_k2); title('FFT bin N-k'); grid on
    nexttile
    semilogx(freqs,Visense_precision_dc); title('FFT bin 0 (DC)'); grid on
    nexttile
    semilogx(freqs,Visense_precision_sum2); title('Sum(|F|^2)'); grid on
    legend(num2str(RLs),'Location','northeastoutside')

    % Vpickup Ch 1
    nexttile
    semilogx(freqs,Vpickup1_precision_k1); ylabel('Vpickup Ch 1'); grid on
    nexttile
    semilogx(freqs,Vpickup1_precision_k2); grid on
    nexttile
    semilogx(freqs,Vpickup1_precision_dc); grid on
    nexttile
    semilogx(freqs,Vpickup1_precision_sum2); grid on

    % Vpickup Ch 2
    nexttile
    semilogx(freqs,Vpickup2_precision_k1); ylabel('Vpickup Ch 2'); grid on
    nexttile
    semilogx(freqs,Vpickup2_precision_k2);  grid on
    nexttile
    semilogx(freqs,Vpickup2_precision_dc);  grid on
    nexttile
    semilogx(freqs,Vpickup2_precision_sum2);  grid on

    xlabel(t,'Frequency (Hz)'); ylabel(t,'Precision (\sigma)');
    title(t,'Precision of Demodulated ADC Data')


end

%%
%--------------------------------------------------------------------------
% Plot overlapping data removed
%--------------------------------------------------------------------------
if plot_rm_overlap
    %--------------------------------------------------------------------------
    % plot options
    ylbl_opts = {'','Voltage (Vpp)','Current (mA)','Resistance (\Omega)','SNR (dB)'};
    x = f_rmo;

    %--------------------------------------------------------------------------
    % Plot Isense and Vload
    %--------------------------------------------------------------------------
    Isense_rmo = Visense_rmo/Rsense;
    Vload_rmo = Vpickup1_rmo - Vpickup2_rmo;
    vars2plot = {'Isense_rmo*1000','Vload_rmo'};
    plt_titles = {'Isense = Visense/Rsense','Vload = Vpickup 1 - Vpickup 2'};
    ylbl_sel = [3 2];   % ylabels on tiles

    %--------------------------------------------------------------------------
    figure;
    t = tiledlayout('horizontal','TileSpacing','compact','Padding','compact');
    for n = 1:length(vars2plot)
        eval(['pltvar = ' vars2plot{n} ';']);
        nexttile
        semilogx(x,pltvar); grid on; hold on
        title(plt_titles{n}), ylabel(ylbl_opts{ylbl_sel(n)})
        for k = 1:size(pltvar,1)   % Get 3dB points and plot
            [i_3dB] = get_3dB_points(pltvar(k,:),2);
            semilogx(x(i_3dB),pltvar(k,i_3dB),'k*')
        end
    end
    lgd_str = [num2str(RLs); '3dB  '];
    lgd = legend(lgd_str,'Location','northeastoutside');
    title(lgd,'Rload (\Omega)')
    xlabel(t,'Frequency (Hz)')
    title(t,'Frequency Response: Sensed Current and Voltage')

    %--------------------------------------------------------------------------
    % Plot ADC voltages and SNR
    %--------------------------------------------------------------------------
    vars2plot = {'Visense_rmo','Vpickup1_rmo','Vpickup2_rmo', ...
        'Visense_snr_rmo','Vpickup1_snr_rmo','Vpickup2_snr_rmo'};
    plt_titles = {'Visense','Vpickup Ch 1','Vpickup Ch 2','','',''};
    ylbl_sel = [2 1 1 5 1 1];   % tile y labels
    is_snr_var = [0 0 0 1 1 1]; % if is_snr, format ylimits and add target line
    %--------------------------------------------------------------------------
    figure;
    t = tiledlayout('flow','TileSpacing','compact','Padding','compact');
    for n = 1:length(vars2plot)
        eval(['pltvar = ' vars2plot{n} ';']);
        nexttile
        semilogx(x,pltvar); grid on; hold on
        title(plt_titles{n}), ylabel(ylbl_opts{ylbl_sel(n)})
        if is_snr_var(n)        % format ylimits and add target line
            ylim(snr_ylims);
            semilogx(x,80*ones(size(x)),'k--','LineWidth',2) % 80 dB target
        else
            for k = 1:size(pltvar,1)   % Get 3dB points and plot
                [i_3dB] = get_3dB_points(pltvar(k,:),2);
                semilogx(x(i_3dB),pltvar(k,i_3dB),'k*')
            end
        end
    end

    % add legend
    nexttile(round(n/2))
    lgd_str = cellstr(num2str(RLs));
    lgd_str{end+1} = '3dB point'; lgd_str{end+1} = '80dB target';
    lgd = legend(lgd_str,'Location','northeastoutside');
    title(lgd,'Rload (\Omega)'), xlabel(t,'Frequency (Hz)')
    title(t,'Voltage Bandwidth and SNR')

    %--------------------------------------------------------------------------
    % Plot precision
    % %--------------------------------------------------------------------------
    %     figure;
    % t = tiledlayout('flow','TileSpacing','compact','Padding','compact');
    % x = [100 1e7];
    % nexttile
    % semilogx(f_rmo,Rload_precision(:,kpIdx)); hold on
    % semilogx(x,ones(size(x)),'k--','LineWidth',2) % 1 Ohm target
    % ylabel(t,'\sigma (\Omega)'), xlabel(t,'Frequency (Hz)'), grid on
    % title(t,'Impedance Precision: Z = Vload/Isense')
    % lgd_str = cellstr(num2str(RLs));
    % lgd_str{end+1} = '1\Omega Target';
    % lgd = legend(lgd_str,'Location','northeastoutside'); title(lgd,'RLoad (\Omega)');

    % Plot impedance precision vs freq
    x = [100 freqs(end)];
    figure;
    t = tiledlayout('horizontal','TileSpacing','compact','Padding','compact');
    nexttile
    semilogx(f_rmo,Rload_precision(:,kp_inds)); hold on
    semilogx(x,ones(size(x)),'k--','LineWidth',2) % 1 Ohm target
    ylabel('\sigma (\Omega)'), grid on
    nexttile
    semilogx(f_rmo,Rload_snr(:,kp_inds)); ylim(snr_ylims); grid on; hold on
    semilogx(x,80*ones(size(x)),'k--','LineWidth',2) % 80 dB target
    ylabel('SNR (dB)')
    title(t,'Impedance Precision and SNR: Z = Vload/Isense')
    xlabel(t,'Frequency (Hz)')
    lgd_str = cellstr(num2str(RLs));
    lgd_str{end+1} = 'Target';
    lgd = legend(lgd_str,'Location','northeastoutside'); title(lgd,'RLoad (\Omega)');


end
%%
%--------------------------------------------------------------------------
% Plot mean demod data with standard deviation shaded
% https://www.mathworks.com/matlabcentral/answers/494515-plot-standard-deviation-as-a-shaded-area
%--------------------------------------------------------------------------
if plot_mean_std

    var1 = {'Visense','Vpickup1','Vpickup2'};   % string, first part of plot vars
    % var2 = {'mean','std','precision'};
    var2 = {'mean','std'};
    var3 = {'k1','k2','dc','sum2'};

    % Set up figure
    figure;
    t = tiledlayout(3,4,'TileSpacing','compact','Padding','compact');
    x = freqs';
    x2 = [x, fliplr(x)];

    % Loop through strings to get plot variable names
    % Calculate and plot mean+/-std
    for i = 1:length(var1)              % Visense, Vpickup1, Vpickup2
        for ii = 1:length(var3)         % k1, k2, dc, sum2

            % Get mean and std curves, concat strings (var2 = mean, std)
            eval(['ymean = ' var1{i} '_' var2{1} '_' var3{ii} ';']);
            eval(['ystd = ' var1{i} '_' var2{2} '_' var3{ii} ';']);
            curve1 = ymean + ystd;
            curve2 = ymean - ystd;
            inBetween = [curve1, fliplr(curve2)];

            % Plot
            nexttile; hold on
            for iii = 1:size(inBetween,1)
                fill(x2,inBetween(iii,:),ones(size(inBetween(iii,:))),'FaceAlpha',0.8);
                % semilogx(x,ymean(iii,:),'Color',pcolors{iii},'LineStyle',':');
            end
            title([var1{i} ' ' var3{ii}]); grid on

        end
        % Add legend at end of row
        legend(num2str(RLs),'Location','northeastoutside')
    end

    title(t,'Extracted Mean \pm Standard Deviation');    % Figure title
    xlabel(t,'Frequency (Hz)'); ylabel(t,'\mu\pm\sigma');

    % Set up figure
    figure;
    t = tiledlayout(3,4,'TileSpacing','compact','Padding','compact');
    x = freqs';
    x2 = [x, fliplr(x)];
    nfiles = length(folder_data);

    % Loop through strings to get plot variable names
    % Calculate and plot mean+/-std
    for i = 1:length(var1)              % Visense, Vpickup1, Vpickup2
        for ii = 1:length(var3)         % k1, k2, dc, sum2

            % Get mean and std curves, concat strings (var2 = mean, std)
            eval(['ymean = ' var1{i} '_' var2{1} '_' var3{ii} ';']);
            eval(['ystd = ' var1{i} '_' var2{2} '_' var3{ii} ';']);
            curve1 = (ymean + ystd)./ymean;
            curve2 = (ymean - ystd)./ymean;
            inBetween = [curve1, fliplr(curve2)];

            % Plot
            nexttile; hold on
            semilogx(x,ones(size(x)),'k--'); % Dashed line at y = 1
            Carray = ones(size(inBetween(iii,:)));
            for iii = 1:size(inBetween,1)
                fill(x2,inBetween(nfiles+1-iii,:),Carray,'FaceAlpha',0.5);
            end
            ylim([1-0.002 1+0.002])
            title([var1{i} ' ' var3{ii}])
            grid on

        end
        % Add legend at end of row
        legend(num2str(RLs),'Location','northeastoutside')
    end

    title(t,'Extracted Normalized Mean \pm Standard Deviation');    % Figure title
    xlabel(t,'Frequency (Hz)'); ylabel(t,'(\mu\pm\sigma)/\mu');
end
