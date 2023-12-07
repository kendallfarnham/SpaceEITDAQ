%--------------------------------------------------------------------------
% User Interface Functions: 64-Channel DAQ Rev 2
%--------------------------------------------------------------------------
% Calculate voltages from fft data
%--------------------------------------------------------------------------
% Inputs: Rload (Vload/Isense data)
%       freqs (freqs)
%       brd_num (board used for acquisition
% Outputs: Rload_cal (calibrated measured load)
%       Vload_cal (calibrated voltage across load, peak-to-peak amplitude)
%       Iload_cal (calibrated current across load)
%--------------------------------------------------------------------------
function [Rload_cal, Rload_cal_single, cf] = calibrate_rpickup_freqsweep(Vpickup, Isense, ...
    freqs, brd_num, plot_results)
%--------------------------------------------------------------------------
% Check inputs
if ~exist('brd_num','var'); brd_num = 0; end  % use default board
if ~exist('plot_results','var'); plot_results = 0; end  % don't show plots
%--------------------------------------------------------------------------
% Get circuit parameters
afe_params = get_circuit_parameters(brd_num);

%--------------------------------------------------------------------------
% Calculate estimated Rload
Rload = Vpickup./Isense;
%--------------------------------------------------------------------------
% Use Rl_calc for calibration calculations
if size(Rload,3) == length(freqs) % 3D matrix, take average to get nfreqs in dim2
    Rl_calc = squeeze(mean(Rload,2));
    mat3D = 1;
else
    Rl_calc = Rload;
    mat3D = 0;
end

%--------------------------------------------------------------------------
% Sort by Rload
mdpt = 30 %round(size(Rl_calc,2)/2);
for k = 1:size(Rl_calc,1)
    RL(k,1) = Rl_calc(k,mdpt);
end
[~,rl_sorti] = sort(RL);    % get sorted indices
Rl_calc = Rl_calc(rl_sorti,:);
Rload = Rload(rl_sorti,:,:);  % sort Rload

%--------------------------------------------------------------------------
% Calculate the linear regression for each frequency
RLs = afe_params.RLs;           % get rloads on resistor board


% initialize matrices
slopes = zeros(size(Rl_calc,2),1);
intercepts = zeros(size(Rl_calc,2),1);
cf = zeros(size(Rl_calc));

use_inds = 4:11; % use these Rload indices for computing cal factor

% Loop through each frequency
for fi = 1:size(Rl_calc,2)
    coefficients = polyfit(Rl_calc(use_inds,fi),Rl_calc(use_inds,fi)./RLs(use_inds),1); % Linear regression

    slopes(fi,1) = coefficients(1);     % Store slope and intercept
    intercepts(fi,1) = coefficients(2);
    cf(:,fi) = coefficients(2) + coefficients(1)*Rl_calc(:,fi);   % get calibration factor at each freq

end

%--------------------------------------------------------------------------
% Get calibration factor per frequency
cf = 1./cf;                 % Invert for linear regression
%--------------------------------------------------------------------------
% Generate linear regression line for midpoint freq
mdpt = 30; %round(size(Rl_calc,2));
x_regression = linspace(min(Rl_calc(:)), max(Rl_calc(:)), 100); % 100 points for a smooth line
y_regression = polyval([slopes(mdpt) intercepts(mdpt)], x_regression);
%--------------------------------------------------------------------------
% Adjust Vload and Isense

if mat3D
    for n = 1:size(Rload,2)
        Rload_cal(:,:,n) = cf.*squeeze(Rload(:,n,:));      % calibrated load using freq sweep cal factor

        Rload_cal_single(:,:,n) = cf(:,mdpt).*squeeze(Rload(:,n,:));
    end
    Rload_cal = permute(Rload_cal,[1 3 2]);
    Rload_cal_single = permute(Rload_cal_single,[1 3 2]);
else
    Rload_cal = cf.*Rload;      % calibrated load using freq sweep cal factor
    Rload_cal_single = cf(:,mdpt).*Rload;
end

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
    t = tiledlayout('horizontal','TileSpacing','tight','Padding','tight');
    nexttile
    if mat3D
        for n = 1:size(Rload,2)
            loglog(freqs,squeeze(Rload(:,n,:))); grid on; title('Rload = Vload \div Isense')
            hold on; loglog(freqs,Rl_actual,'--'); ylabel('Resistance (\Omega)')
            ylim([1 10e3])
        end

        nexttile
        for n = 1:size(Rload,2)
            loglog(freqs,squeeze(Rload_cal(:,n,:))); grid on; title('Adjusted Rload (CF per Frequency)')
            hold on; loglog(freqs,Rl_actual,'--')
               ylim([1 10e3])
        end
        nexttile
        for n = 1:size(Rload,2)
            loglog(freqs,squeeze(Rload_cal_single(:,n,:))); grid on; title('Adjusted Rload (CF at 19.7 kHz)')
            hold on; loglog(freqs,Rl_actual,'--')
               ylim([1 10e3])
        end
    else

        loglog(freqs,Rload); grid on; title('Rload = Vload \div Isense')
        hold on; loglog(freqs,Rl_actual,'--'); ylabel('Resistance (\Omega)')
        nexttile
        loglog(freqs,Rload_cal); grid on; title('Adjusted Rload (CF per Frequency)')
        hold on; loglog(freqs,Rl_actual,'--')

        nexttile
        loglog(freqs,Rload_cal_single); grid on; title('Adjusted Rload (CF at 19.7 kHz)')
        hold on; loglog(freqs,Rl_actual,'--')
    end
    lgd = legend(cellstr(num2str(RLs)),'Location','northeastoutside'); title(lgd,'RLoad (\Omega)')
    title(t,'Calibrating Measured Load Resistance (Rload = Vload/Isense)')
    xlabel(t,'Frequency (Hz)')
    %--------------------------------------------------------------------------
    % Plot ratio for determining Calibration Factor
    %--------------------------------------------------------------------------
    figure;
    colororder(newcolors)
    t = tiledlayout('flow','TileSpacing','compact','Padding','compact');
    %--------------------------------------------------------------------------
    % plot all frequencies
    nexttile
    plot(Rl_calc,Rl_calc./RLs); grid on
    title(sprintf('Frequencies %.f Hz to %.1f MHz',freqs(1),freqs(end)/1e6));
    xlabel('Rload = Vload/Isense'), ylabel('Rload/R(Actual)');


    %--------------------------------------------------------------------------
    % plot it
    nexttile
    plot(Rl_calc(:,mdpt),Rl_calc(:,mdpt)./RLs,'DisplayName','19.7 kHz data');  grid on; hold on
    plot(x_regression,y_regression,'k--','DisplayName','Linear Regression'); % Plot regression line
    legend('Location','northeast')
    % Add the equation text
    equationText = sprintf('y = %.5fx + %.5f', slopes(mdpt), intercepts(mdpt));
    textLocation = [0.5*mean(Rl_calc(:,mdpt)), 0.5*mean(Rl_calc(:,mdpt)./RLs)]; % Adjust these values as needed for best appearance
    text(textLocation(1), textLocation(2), equationText, 'FontSize', 11);
    title(sprintf('Calibration Frequency %.1f kHz',freqs(mdpt)/1e3));
    xlabel('Rload = Vload/Isense'), ylabel('Rload/R(Actual)');


    %--------------------------------------------------------------------------
    nexttile
    semilogx(freqs,slopes);  title('Linear Regression Slope'); grid on
    xlabel('Frequency (Hz)')
    nexttile
    semilogx(freqs,intercepts);  title('Linear Regression Intercepts'); grid on
    xlabel('Frequency (Hz)')
    % nexttile
    % loglog(freqs,Rload_cal); grid on; title('Adjusted Rload ')
    % hold on; loglog(freqs,Rl_actual,'--')
    title(t,'Calibration Factor for Adjusting Measured Rload');
end
