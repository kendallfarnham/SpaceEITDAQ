%--------------------------------------------------------------------------
% User Interface Functions: 64-Channel DAQ Rev 2
%--------------------------------------------------------------------------
% Calculate voltages from fft data
%--------------------------------------------------------------------------
% Inputs: Fvpickup1 (FFT data for Vpickup1 signal bin, half spectrum data)
%       Fvpickup2 (FFT data for Vpickup 2 signal bin, half spectrum data)
%       Gpga (PGA gains for Vpickup1 and Vpickup2 ADCs)
% Outputs: Vpp (peak-to-peak amplitude)
%       Vrms (RMS amplitude)
%--------------------------------------------------------------------------
function [Vpp, Vrms] = calc_vload_from_vpickup_fft(Fvpickup1,Fvpickup2, Gpga, ...
    board_num)

%--------------------------------------------------------------------------
% Get circuit parameters
if ~exist('board_num','var')
    afe_params = get_circuit_parameters;
else
    afe_params = get_circuit_parameters(board_num);
end
%--------------------------------------------------------------------------
% Fixed circuit gains on AFE
Gdriver = afe_params.Gdriver;   % Gain on ADC driver 
Gvpu = afe_params.Gvpu;         % Gain on voltage pickup op amp
ADC_FSV = afe_params.ADC_FSV;   % fullscale amplitude 
sf = afe_params.sf;     % Scaling factor = 2^B - 1 (full range of ADC, B=16) 

%--------------------------------------------------------------------------
% Calculate Circuit gains
Gckt = Gvpu*Gdriver*Gpga;      % voltage pickup circuit gains
% check size, copy to second pga if dne
if length(Gckt) < 2
    Gckt(2) = Gckt;
end

%--------------------------------------------------------------------------
% Calculate Voltages
% Voltage = (Magnitude/ScalingFactor) * Vref
Vpp_v1 = 2*abs(Fvpickup1)/sf * ADC_FSV / Gckt(1); % Pk-pk amplitude (x2 because using half spectrum)
Vpp_v2 = 2*abs(Fvpickup2)/sf * ADC_FSV / Gckt(2);
Vpp = abs(Vpp_v1-Vpp_v2);   % Get voltage across load
Vrms = Vpp/(2*sqrt(2));     % Rms amplitude

end