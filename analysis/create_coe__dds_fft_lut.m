% LUT of signal freq, DDS phase bits, and FFT sampling freq and bin
% Set desired signal frequencies, translate to DDS phase input and FFT bin
%   FFT resolution = fs/N ------------> fs/2
%       signal freq f will land in bins k = f*N/fs and N-k
%   DDS resolution = fclk/(2^B)
%       signal freq f = fclk * phase_bits/(2^B)
%       phase_bits[B-1 downto 0] = f/fclk * 2^B
%   **Use prime number bin freqs for highest SNR
% Store LUT in excel spreadsheet 
% File updated: 6/30/2023
%--------------------------------------------------------------------------
clear all; 
close all; clc;
addpath ../mfiles/

% System parameters
dclk = 100e6;               % DDS clock frequency
aclk = 14287510;            % ADC sampling frequency
% aclk = 10e6;
fft_width = 10;
nfft = 2^fft_width;         % Number of FFT bins
dds_phase_width = 24;       % Number of bits in DDS phase input
bram_data_width = 24;       % Data width of ROM
clkdiv = 128;               % clock divide for slower sampling rate
nfreqs = 64;                % number of freqs in sweep (per sampling freq)

save_lut_to_file = false;   % If true, table will be saved to Excel 
write_coe = false;           % Write coe file 

%--------------------------------------------------------------------------
% Output file name to save LUT to
% ofname = ['dds-lut_' num2str(fft_width) 'bit-fft_' ...
%     num2str(dds_phase_width) 'bit-phase_' ...
%     num2str(dclk/1E6) 'M-dclk_div' num2str(clkdiv) '_' ...
%     num2str(nfreqs) 'freqs_prime-bins.xlsx'];
% ofname = ['dds-lut_' num2str(aclk/1E6) 'M-aclk_' ...
%     num2str(dclk/1E6) 'M-dclk_div' num2str(clkdiv) '_' ...
%     num2str(nfreqs) 'freqs_prime-bins.xlsx'];
ofname = ['dds-lut_15M-aclk_' ...
    num2str(dclk/1E6) 'M-dclk_div' num2str(clkdiv) '_' ...
    num2str(nfreqs) 'freqs_prime-bins_w_alias.xlsx'];
%--------------------------------------------------------------------------
% Calculate signal frequencies from FFT, translate to DDS phase input
fsamp = [aclk/clkdiv aclk]; % FFT sampling freqs 

%--------------------------------------------------------------------------
% Get signal bins for one sampling freq (will concatonate after)
%--------------------------------------------------------------------------
% 1. This results in 32 freqs per fsamp for NFFT=1024
k(1) = 1;
for ii = 1:nfft/2
    if k(ii)+ii < nfft/2
        k(ii+1) = k(ii)+ii;
    else
        break
    end
end

% 2. All frequencies
kbw = 1:nfft/2;   

% 3. Log ks
klog(1) = 1;
for ii = 1:nfft/2
    if klog(ii)+ii^2 < nfft/2
        klog(ii+1) = klog(ii)+ii^2;
    else
        break
    end
end

% 4. Prime ks
kprime = [1, primes(nfft/2-1)];
idx1 = 1:8;
indx_log = round(logspace(1,log10(0.7*length(kprime)),nfreqs/2-idx1(end)));
idx2 = [idx1, indx_log];
k = kprime(idx2);

% k = k2;     % Use log bins

%--------------------------------------------------------------------------
% Compare freqs for high and low sampling rates
fsig1 = k' .* fsamp(1)/nfft;
fsig2 = k' .* fsamp(2)/nfft;
fft_cmp = [fsig1 fsig2];
%%
nks = length(k)
%--------------------------------------------------------------------------
% Get fft freqs
fsig(1:nks,1) = k' .* fsamp(1)/nfft;
fsig(nks+1:2*nks,1) = k' .* fsamp(2)/nfft;

% fft bins and sampling freqs
k = [k k]; % concatenate
fs = ones(size(fsig));
fs(1:nks) = fsamp(1);
fs(nks+1:end) = fsamp(2);

%--------------------------------------------------------------------------
% Find DDS frequencies nearest fsig
df = dclk/(2^dds_phase_width);  % DDS frequency resolution
fdds = round(fsig/df) * df;     % round the multiplier values f/df

%--------------------------------------------------------------------------
% Find indices of the aliased bins
aliased_k = compute_alias_fft_bins(k,aclk,nfft,clkdiv);
aliased_k(nfreqs/2+1:end) = k(nfreqs/2+1:end);


%--------------------------------------------------------------------------
% Plot bandwidth coverage and dds-to-fft error
figure;
subplot 221;
semilogx(fdds,(fdds-fsig),'b-o');
% xlabel('Signal Frequency (Hz)');
ylabel('Absolute Error (Hz)'); 
title('AE = f_{DDS}-f_{FFT}')
grid on

subplot 223;
semilogx(fdds,100*(fdds-fsig)./fdds,'b-o'); 
xlabel('Signal Frequency (Hz)');
ylabel('Relative Error (%)'); 
title('RE = (f_{DDS}-f_{FFT})/f_{DDS}')
grid on

subplot(2,2,[2,4]);
loglog(fdds,fsig,'k-o')
xlabel('DDS Frequency (Hz)');
ylabel('FFT In-Bin Frequency (Hz)');
title('Bandwidth Coverage')
grid on

sgtitle('DAQ DDS and FFT Frequency Matching')

%--------------------------------------------------------------------------
% Convert frequency to DDS phase (dds_phase_width bits wide)
inbin_freq_codes = round(fsig/dclk * (2^dds_phase_width));
phase_bit = int2bit(inbin_freq_codes',bram_data_width);
phase_hex = binaryVectorToHex(phase_bit');

%--------------------------------------------------------------------------
% Create table and write to Excel file
col_names = {'DDS fout','DDS phase hex','FFT fs','FFT bin','FFT bin hex'};
fout_col = fsig;
fft_k_col = k';
fft_fs_col = fs;
fft_k_bit = int2bit(k,16);      % hex, 16 bits
fft_k_hex = binaryVectorToHex(fft_k_bit');


lut = table(fout_col,phase_hex,fft_fs_col,fft_k_col,fft_k_hex,'VariableNames',col_names);

%--------------------------------------------------------------------------
% Save it
if save_lut_to_file
    writetable(lut,ofname)
    save(strrep(ofname,'.xlsx','.mat'))
end

%--------------------------------------------------------------------------
% Write phase bits and fft bins to coe files
if write_coe
    % Write phase bit coe file
    coefile = ['coe-dds__' strrep(ofname,'.xlsx','.coe')];
    write2coe(coefile,phase_hex,16);

    % Write fft bin coe file
    coefile = ['coe-k__' strrep(ofname,'.xlsx','.coe')];
    write2coe(coefile,fft_k_hex,16);


    % Write fft alias bin coe file
    fft_alias_k_bit = int2bit(aliased_k,16);
    coefile = ['coe-alias-k__' strrep(ofname,'.xlsx','.coe')];
    write2coe(coefile,binaryVectorToHex(fft_alias_k_bit'),16);
end
