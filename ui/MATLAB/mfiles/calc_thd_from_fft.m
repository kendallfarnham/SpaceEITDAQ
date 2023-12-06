%--------------------------------------------------------------------------
% User Interface Functions: 64-Channel DAQ Rev 2
%--------------------------------------------------------------------------
% Compute THD from FFT data
% Sources: 
%   https://www.sjsu.edu/people/burford.furman/docs/me120/FFT_tutorial_NI.pdf
%   https://www.analog.com/media/en/training-seminars/design-handbooks/Practical-Analog-Design-Techniques/Section8.pdf
%--------------------------------------------------------------------------
% Inputs: fk (real or complex FFT data for signal bin(s))
%       sumf2 (sum of |FFT|^2)
% Optional inputs:
%       half_spectrum (sum includes half (1) or full (0) spectrum FFT data)
% Outputs: thd (total harmonic distortion)
%--------------------------------------------------------------------------
function [thd] = calc_thd_from_fft(fk, sumf2, half_spectrum)

% Check optional inputs, set defaults in DNE
if ~exist('half_spectrum','var')
    half_spectrum = 1;      % default, sum uses half spectrum (bins 1 to N/2-1)
end

%--------------------------------------------------------------------------
% Calculate THD
fk2 = abs(fk).^2;  % signal |F|^2, remove from sum to get harmonics only

if half_spectrum            % Sum includes bins 1 to NFFT/2-1
    thd = sqrt(sumf2-fk2)./sqrt(fk2);
else                        % Sum includes bins 1 to NFFT
    thd = sqrt(sumf2/2-fk2)./sqrt(fk2);    % divide sum^2 in half per symmetry
end
