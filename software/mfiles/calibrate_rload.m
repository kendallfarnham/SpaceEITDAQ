%--------------------------------------------------------------------------
% User Interface Functions: 64-Channel DAQ Rev 2
%--------------------------------------------------------------------------
% Calibrate Rload 
%--------------------------------------------------------------------------
% Inputs: Rload (Vload/Isense data)
%       freqs (freqs)
%       brd_num (AFE board used for acquisition)
%       no_mux (T/F mux board used for acquisition)
%       plot_results (T/F show plots)
% Outputs: Rload_cal (calibrated measured load)
%       Vload_cal (calibrated voltage across load, peak-to-peak amplitude)
%       Iload_cal (calibrated current across load)
%--------------------------------------------------------------------------
function [Rload_cal, cf, Vpu_Vdivide_gain] = calibrate_rload(Rload, ...
    freqs, brd_num, no_mux, plot_results)
%--------------------------------------------------------------------------
% Check inputs
if ~exist('brd_num','var'); brd_num = 0; end  % use default board
if ~exist('no_mux','var'); no_mux = 0; end  % default is to use mux
if ~exist('plot_results','var'); plot_results = 0; end  % don't show plots
%--------------------------------------------------------------------------
% Get circuit parameters
afe_params = get_circuit_parameters(brd_num);

%--------------------------------------------------------------------------
% RC values
Cdc = afe_params.Cdc;           % DC blocking cap value
Rvpickup = afe_params.Rvpickup; % vpickup circuit input resistance
Rmux = afe_params.Rmux;         % Mux on resistance
Cmux = afe_params.Cmux;         % Mux source/drain capacitance

%--------------------------------------------------------------------------
% Calculate cap impedances
ZCdc = 1./(1i*2*pi*freqs*Cdc);
ZCmux = 1./(1i*2*pi*freqs*Cmux);

%--------------------------------------------------------------------------
% Calculate circuit impedances starting from Vpickup input back to Rsense
%--------------------------------------------------------------------------
% Zvpu -> Z on the input of Vpickup PCB
% Zload -> refering to load on Vsource (Z including Rload and || Zpickup/Zmux)
%--------------------------------------------------------------------------
% Calculate Z at input of Vpickup PCB, not including load (in parallel)
if no_mux
    Zvpu = ZCdc + Rvpickup;
else
    Zvpu = ZCdc + 1./(1./ZCmux + 1./(Rmux + 1./(1/Rvpickup + 1./ZCmux)));
    % Zvpu = ZCdc + Rmux + Rvpickup;
end
Zvpu = Zvpu';
%--------------------------------------------------------------------------
% Use Rl_calc for calibration calculations
if size(Rload,3) == length(freqs) % 3D matrix, take average to get nfreqs in dim2
    Rl_calc = squeeze(mean(Rload,2));
else
    Rl_calc = Rload;
end

%--------------------------------------------------------------------------
% Calculate load on Vsource, Zload = Rload+Zvpu || Zvpu
% Calculate reverse gain on voltage pickup (voltage divider with vpickup Zin)
for n = 1:size(Rl_calc,1)
    Zload(n,:) = real(1./(1./(Rl_calc(n,:)+Zvpu)+ 1./Zvpu));
    Vpu_Vdivide_gain(n,:) = real(Zvpu./(2*Zvpu+Rl_calc(n,:)));
end
%--------------------------------------------------------------------------
% Adjust Vload and Isense
if size(Rl_calc,2) == 64
    mdpt = 30;      % pick a high snr frequency
else
    mdpt = round(size(Rl_calc,2));
end
cf = 1.765 - 0.0005638*Rl_calc(:,mdpt);   % get calibration factor, select a midpt freq
cf = 1./cf;
Rload_cal = cf.*Rload;                      % calibrated load
% Iload_cal = Isense .* Vpu_Vdivide_gain;     % Rload = Vload/Iload_cal
% Vload_cal = Vload./Vpu_Vdivide_gain;        % Rload = Vload_cal/Isense

if exist('plot_results','var') && plot_results
    %--------------------------------------------------------------------------
    % Set up plot parameters
    %--------------------------------------------------------------------------
    figure;
    colororder("gem12");
    C = colororder;
    if size(C,1) > size(Rload,1)
        newcolors = C(1:size(Rload,1),:);
        colororder(newcolors)
    end
    RLs = afe_params.RLs;           % get rloads on resistor board
    Rl_actual = repmat(RLs,[1 length(freqs)]);
    %--------------------------------------------------------------------------
    % Plot calculated Rload vs calibrated
    %--------------------------------------------------------------------------
    t = tiledlayout('horizontal','TileSpacing','compact','Padding','compact');
    nexttile
    loglog(freqs,Rload); grid on; title('Rload = Vload \div Isense')
    hold on; loglog(freqs,Rl_actual,'--')
    nexttile
    loglog(freqs,Rload_cal); grid on; title('Adjusted Rload ')
    hold on; loglog(freqs,Rl_actual,'--')

    lgd = legend(cellstr(num2str(RLs)),'Location','northeastoutside'); title(lgd,'RLoad (\Omega)')
    title(t,'Calibrating Measured Load Resistance (Rload = Vload/Isense)')
    xlabel(t,'Frequency (Hz)')
    %--------------------------------------------------------------------------
    % Plot ratio for determining Calibration Factor
    figure;
    t = tiledlayout('horizontal','TileSpacing','compact','Padding','compact');
    nexttile
    plot(Rl_calc,Rl_calc./RLs);  title('All Frequencies Plotted'); grid on
    xlabel(sprintf('Frequencies %.f Hz to %.1f MHz',freqs(1),freqs(end)/1e6));
    nexttile
    plot(Rl_calc(:,mdpt),Rl_calc(:,mdpt)./RLs);  title('Frequency Used for Calibration'); grid on
        xlabel(sprintf('Calibration Frequency %.1f kHz',freqs(mdpt)/1e3));
    xlabel(t,'Rload = Vload/Isense'), ylabel(t,'Rload/RL(Actual)');
    title(t,'Calibration Factor for Adjusting Measured Rload')
end
