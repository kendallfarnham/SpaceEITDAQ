%--------------------------------------------------------------------------
% User Interface Functions: 64-Channel DAQ Rev 2
%--------------------------------------------------------------------------
% Calculate voltages from fft data
%--------------------------------------------------------------------------
% Inputs: Fk (real/complex FFT data for signal bin, half spectrum data)
%       Fdc (FFT data for bin 0, real only)
%       nAdc (1: isense, 2: vpickup1, 3: vpickup2)
%       Gpga (PGA gain, optional -- default 1)
% Outputs: Vpp (peak-to-peak amplitude)
%       Vrms (RMS amplitude)
%       Vdc (DC offset)
%--------------------------------------------------------------------------
function [Vpp, Vrms, Vdc] = calc_voltage_from_fft(Fk, Fdc, nAdc, Gpga, board_num)

%--------------------------------------------------------------------------
% Get circuit parameters
if ~exist('board_num','var')
    afe_params = get_circuit_parameters;
else
    afe_params = get_circuit_parameters(board_num);
end
%--------------------------------------------------------------------------
% Fixed circuit gains on AFE
Giamp = afe_params.Giamp;       % I-amp gain
Gdriver = afe_params.Gdriver;   % Gain on ADC driver
Gvpu = afe_params.Gvpu;         % Gain on voltage pickup op amp
ADC_FSV = afe_params.ADC_FSV;   % fullscale amplitude
sf = afe_params.sf;     % Scaling factor = 2^B - 1 (full range of ADC, B=16) 

if ~exist('Gpga','var')
    Gpga = 1;       % set default pga gain to +1
end

%--------------------------------------------------------------------------
% Calculate Circuit gains
if nAdc == 1
    Gckt = Giamp*Gdriver*Gpga;     % isense circuit
else
    Gckt = Gvpu*Gdriver*Gpga;      % voltage pickup circuit
end

Gckt = Gckt/4;      % FFT transform factor

%--------------------------------------------------------------------------
% Calculate Voltages
% Voltage = (Magnitude/ScalingFactor) * Vref
Vpp = 2*abs(Fk)/sf * ADC_FSV / Gckt; % Pk-pk amplitude (x2 because using half spectrum)
Vrms = Vpp*sqrt(2)/2;                % Rms amplitude
Vdc = Fdc/sf * ADC_FSV / Gckt;       % DC offset

end