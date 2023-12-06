%--------------------------------------------------------------------------
% User Interface Functions: 64-Channel DAQ Rev 2
%--------------------------------------------------------------------------
% Calculate voltages from fft data
%--------------------------------------------------------------------------
% Inputs: 
%       Fvisense (FFT data for Visense signal bin, half spectrum data)
%       Fvpickup1 (FFT data for Vpickup 1 signal bin, half spectrum data)
%       Fvpickup2 (FFT data for Vpickup 2 signal bin, half spectrum data)
%       Gpgas (PGA gains for Isense, V1, V2 ADCs)
%       freqs (freqs)
%       no_mux (T/F)
% Outputs: Vload_cal (calibrated voltage across load, peak-to-peak amplitude)
%       Iload_cal (calibrated current across load)
%--------------------------------------------------------------------------
function [Vload_cal, Iload_cal, Rload_cal] = calibrate_afe_voltages ...
    (Fvisense, Fvpickup1, Fvpickup2, Gpgas, freqs, no_mux, board_num)

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
sf = afe_params.sf;             % Scaling factor = 2^B - 1 (full range of ADC, B=16) 

%--------------------------------------------------------------------------
% RC values
Cdc = afe_params.Cdc;           % DC blocking cap value
Rsense = afe_params.Rsense;     % sense resistor value
Rvpickup = afe_params.Rvpickup; % vpickup circuit input resistance
Rmux = afe_params.Rmux;         % Mux on resistance
Cmux = afe_params.Cmux;         % Mux source/drain capacitance

%--------------------------------------------------------------------------
% Calculate cap impedances
ZCdc = 1./(1i*2*pi*freqs*Cdc);
ZCmux = 1./(1i*2*pi*freqs*Cmux);

%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
% Calculate voltages from FFT data
%--------------------------------------------------------------------------
% Calculate Circuit gains
Gckt(1) = Giamp*Gdriver*Gpgas(1);   % isense circuit
Gckt(2) = Gvpu*Gdriver*Gpgas(2);    % voltage pickup circuit
Gckt(3) = Gvpu*Gdriver*Gpgas(3);    % voltage pickup circuit

%--------------------------------------------------------------------------
% Adjust voltages per circuit gains/filters
% Pk-pk amplitude (x2 because using half spectrum)
Visense = 2*abs(Fvisense)/sf * ADC_FSV / Gckt(1);
Vpickup1 = 2*abs(Fvpickup1)/sf * ADC_FSV / Gckt(2); 
Vpickup2 = 2*abs(Fvpickup2)/sf * ADC_FSV / Gckt(3);

%--------------------------------------------------------------------------
% Calculate measured current (Isense) and load current (V1-V2)
Isense = Visense/Rsense;        % sensed current
Vload = Vpickup1 - Vpickup2;    % voltage across load

%--------------------------------------------------------------------------
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
    % Zvpu = ZCdc + 1./(1./ZCmux + 1./(Rmux + 1./(1/Rvpickup + 1./ZCmux)));      
    Zvpu = ZCdc + Rmux + Rvpickup;
end

%--------------------------------------------------------------------------
% Estimate load from sensed current and load voltage
Rload = Vload./Isense;
if length(Zvpu) ~= size(Rload,2)
    Rload = Rload';
    Isense = Isense';
    Vload = Vload';
end

    
for n = 1:size(Vload,2)

    %--------------------------------------------------------------------------
    % Calculate load on Vsource, Zload = Rload+Zvpu || Zvpu
    Zload(:,n) = real(1./(1./(Rload(:,n)+Zvpu(n))+ 1./Zvpu(n)));

    %--------------------------------------------------------------------------
    % Calculate actual voltage and current coming out of Vsource
    Iload_cal(:,n) = Isense(:,n).*real(Zvpu(n)./(2*Zvpu(n)+Rload(:,n)));
    Rload_cal(:,n) = Vload(:,n)./Iload_cal(:,n);

    %--------------------------------------------------------------------------
    % Calculate actual voltage and current coming out of Vsource
    Vload_cal(:,n) = Isense(:,n) .* real(Zload(:,n));


end



