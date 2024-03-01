%--------------------------------------------------------------------------
% User Interface Functions: 64-Channel DAQ Rev 2
%--------------------------------------------------------------------------
% Get circuit parameters for calculating voltages from demod data
% I-amp gain: G = 1 + 9.9k/Rgain
%--------------------------------------------------------------------------
% Input: brd (1 = AFE PCBA, 2 = AFE-MUX Assembly, 3 = AFE w/replaced iamp
%--------------------------------------------------------------------------
function [afe_params] = get_circuit_parameters(brd)

%--------------------------------------------------------------------------
% Get board-specific parameters
if ~exist('brd','var'); brd = 2; end
switch brd
    case 1
        Giamp = 1;          % I-amp gain +1, Rgain = open
        Rsense = 100;       % sense resistor
    case 2
        Giamp = 1.99;       % I-amp gain +2, Rgain = 10k
        Rsense = 100;
    case 3
        Giamp = 1+9.9/2.4;  % I-amp gain +5, Rgain = 2.4k
        Rsense = 50;
    otherwise

        % Default to board 2
        Giamp = 1.99;       % I-amp gain +2, Rgain = 10k
        Rsense = 100;
end


%--------------------------------------------------------------------------
% Fixed circuit gains on AFE
afe_params.Giamp = Giamp;      % I-amp gain
afe_params.Gdriver = 2;        % Gain on ADC driver 
afe_params.Gvpu = 1;           % Gain on voltage pickup op amp

%--------------------------------------------------------------------------
% AFE RC values
afe_params.Cdc = 10e-6;        % DC blocking cap value
afe_params.Rsense = Rsense;    % sense resistor value
% afe_params.Rvpickup = 1e5;   % vpickup circuit input resistance
afe_params.Rvpickup = 1e3;     % vpickup circuit input resistance
afe_params.Cvpickup = 1e-12;   % vpickup circuit parallel input capacitance
afe_params.Rmux = 70;          % Mux on resistance
afe_params.Cmux = 45e-12;      % Mux source/drain capacitance

%--------------------------------------------------------------------------
% ADC parameters
B = 16;     % 16-bit ADC
afe_params.B = B;              % 16-bit ADC
afe_params.ADC_FSV = 4.096;    % fullscale amplitude 
afe_params.sf = 2^B - 1;       % Scaling factor = 2^B - 1 (full range of ADC) 

%--------------------------------------------------------------------------
% Hardware parameters
afe_params.fft_sc = 4;         % FFT scaling factor

%--------------------------------------------------------------------------
% EIT calibration factors for measured Rload
%--------------------------------------------------------------------------
% Given Rload = Vload/Isense, inverted cal factor 1/cf = 1.765-0.0005638*Rload
xload = 1:10e3;                     % linear fit x (Rload)
ylinfit = 1.765 - 0.0005638*xload;  % linear fit for calibration factor inverse
cf = 1./ylinfit;    % cal factor (RloadCal = cf*Rload)
%--------------------------------------------------------------------------
% Save linear fit to param struct
afe_params.Rload_inv_cf_slope = -0.0005638; % slope of linear fit
afe_params.Rload_inv_cf_yint = 1.765;       % y intecept of linear fit
afe_params.Rload_cf_x = xload;      % cal factor x (Rload)
afe_params.Rload_cf_y = cf;         % cal factor y (RloadCal = cf*Rload)

%--------------------------------------------------------------------------
% Used for hardware characterization...
%--------------------------------------------------------------------------
% Loads on resistor board
afe_params.RLs = [10,50,100,200,300,500,1e3,2e3,3e3,5e3,10e3]';

% Load frequencies from phase LUT mat file
coe_filename = ['G:\Shared drives\KF PhD Documents\MATLAB\2023_AFE_Rev2_UI\coe' ...
    '\dds-lut_10bit-fft_24bit-phase_100M-dclk_div128_64freqs_prime-bins.mat'];
load(coe_filename,'k','fsig');
afe_params.freqs = fsig;
afe_params.bins = k;

end