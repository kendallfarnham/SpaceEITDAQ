%--------------------------------------------------------------------------
% User Interface Functions: 64-Channel DAQ Rev 2
%--------------------------------------------------------------------------
% Timing Characteristics
%--------------------------------------------------------------------------
% Inputs (acquisition parameters)
%   nchs  = number of mux channels to use
%   nfreqs = number of freqs to acquire
%   nskips = number of ii skip patterns (per channel), set to 0 for exhaustive
%           non-reciprocal pairs (i.e., n(n-1)/2 pairs)
%   navgs = number of datasets/averages to acquire
%   nsamps = number of samples in the FFT
%--------------------------------------------------------------------------
% Outputs
%   total_t = total acquisition time
%   daq_t = digital acquisition/demodulation time per dataset (not including data tx)
%   ndsets = number of datasets acquired
%--------------------------------------------------------------------------
function [total_t, daq_t, ndsets] = get_acquisition_time(nchs,nfreqs,nskips,navgs,nsamps)
%--------------------------------------------------------------------------
% Define clock periods
sysclk = 10e-9;         % 100 MHz system clock period
uart_clk = 1/256000;    % 256k baud rate
pga_clk = 1/(1e6);      % pga clock period
aclk = 70e-9;           % adc clock period
%--------------------------------------------------------------------------
% ADC to demod timing
% nfft = 1024;                  % number of samples collected
adc_samp_t = nsamps * aclk;     % adc sampling time (fifo write)
fft_read_t = nsamps * sysclk;   % time to read fifo to fft block
fft_comp_t = 112 * sysclk;      % fft computation time (112 clock cycles)
demod_comp_t = nsamps * sysclk; % time to read fft spectrum data
dds_dly_t = nsamps * sysclk;    % internal delay time after switching freqs
daq_t = adc_samp_t + fft_read_t + fft_comp_t + demod_comp_t; % acquisition time
%--------------------------------------------------------------------------
% UART timing parameters
nbits_uart = 10;        % width of data packet: 8-bit data with start and stop bit
uart_cmd_t = nbits_uart * uart_clk; % time to receive/send uart packet
% UART transmit time per dataset acquired
nbram_8bits = 18;       % 9 16-bit data sent per dataset
nadcs = 3;              % number of adcs sending data serially
uart_tx_t = nadcs * nbram_8bits * uart_cmd_t + dds_dly_t;    % data transmit time
%--------------------------------------------------------------------------
% PGA parameters
pga_dly = 1e-3;         % delay through PGA (settling time)
nspi_bits = 16;         % width of serial data packet
pga_set_t = nspi_bits*pga_clk + pga_dly;    % time to set PGA
%--------------------------------------------------------------------------
% MUX timing parameters
mux_dly = 50e-6;         % mux settling time: ton max = 450ns, toff max = 435 ns
set_iivv_t = 10*uart_cmd_t + mux_dly;    % time to set all 4 sets of muxes
set_vv_t = 6*uart_cmd_t + mux_dly;      % time to switch vpickup muxes

%--------------------------------------------------------------------------
% Acquisition Steps
%--------------------------------------------------------------------------
% 1. Set mux, wait delay --> UART command (10bits*baud) + delay
% 2. Acquire NFFT samples for demod --> NFFT*fsamp
% 3. Wait for FFT to compute
% 4. Read full spectrum & perform calculations --> NFFT*syclk
% 5. Send data back to user --> UART (nadcs*ndata*10bits*baud)
% -- Repeat 2-5 x nfreqs
% -- Repeat 1-5 x n_iis x n_vvs
%--------------------------------------------------------------------------
% Compute total acquisition time
if nskips == 0
    n_iis = nchs*(nchs-1)/2;% total number of exhaustive, non-reciprocal ii pairs
else
    n_iis = nchs*nskips;    % total number of ii pairs (using skip patterns)
end
n_vvs = round(nchs/2);  % total number of vpickup measurements per ii pair
ndsets = n_iis*n_vvs*nfreqs*navgs;  % total number of datasets to acquire
%--------------------------------------------------------------------------
% Set all muxes n_ii times: set_iivv_t * n_iis;
t1 = set_iivv_t * n_iis;
% Set vv muxes n_vv-1 times per n_ii: set_vv_t * (n_vvs-1) * n_iis;
t2 = set_vv_t * n_iis*(n_vvs-1);
% Set frequency for each mux set: dds_dly_t * n_iis * n_vvs * (nfreqs-1)
t3 = dds_dly_t * n_iis*n_vvs*(nfreqs-1);
% Acquire data, send to user x ndsets = n_iis * n_vvs * nfreqs * navgs 
t4 = (daq_t + uart_tx_t) * ndsets;
%--------------------------------------------------------------------------
% Total time
total_t = t1 + t2 + t3 + t4;


end
