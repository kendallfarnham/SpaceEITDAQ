%--------------------------------------------------------------------------
% User Interface Functions: 64-Channel DAQ Rev 2
%--------------------------------------------------------------------------
% Timing Characteristics
%--------------------------------------------------------------------------
clear all
close all

addpath mfiles
%--------------------------------------------------------------------------
% % Acquisition parameters
% nchs = 4;           % number of mux channels to use
% nfreqs = 1;         % number of freqs to acquire
% nskips = 1;         % number of ii skip patterns (per channel)
% navgs = 1;          % number of datasets/averages to acquire
% nsamps = 1024;      % number of samples in the FFT
%--------------------------------------------------------------------------
% Get timing per channel count and freqs
%--------------------------------------------------------------------------
nsamps = 1024;
nskips = 1; navgs = 1;
% [total_t, daq_t, ndsets] = get_acquisition_time(nchs,nfreqs,nskips,navgs,nsamps);
for nchs = 1:64
    for nfreqs = 1:64
        [total_t, daq_t, ndsets] = get_acquisition_time(nchs,nfreqs,nskips,navgs,nsamps);
        t_vs_freq(nchs,nfreqs) = total_t;
        daq_t_vs_freq(nchs,nfreqs) = daq_t;
        nsets1(nchs,nfreqs) = ndsets;
    end
end

%--------------------------------------------------------------------------
% Plot
%--------------------------------------------------------------------------
chs = 1:64;
fps_target = 1/30 *ones(size(chs)); % 30 fps target
%--------------------------------------------------------------------------
figure;
t_curve(1,:) = t_vs_freq(:,1);                       % total time
daq_t_curve(1,:) = nsets1(:,1).*daq_t_vs_freq(:,1);  % acquisition time
lb_y_curve = min(daq_t_curve) *ones(size(chs)); % lower bound y curve
semilogy(chs,t_curve,'k','LineWidth',2); hold on
semilogy(chs,daq_t_curve,'b');

% Fill in between curves
fillx = [chs, fliplr(chs)];
filly = [daq_t_curve, fliplr(t_curve)];
fill(fillx,filly,'b','FaceAlpha',0.5)
filly = [lb_y_curve, fliplr(daq_t_curve)];
fill(fillx,filly,'r','FaceAlpha',0.5)
semilogy(chs,fps_target,'k--');

ylimits = [min(lb_y_curve) 100];
xlim([1 max(chs)]); ylim(ylimits); grid on
legend('total time','','data tx time','data acq time','30 fps target','Location','northeastoutside')
xlabel('Number of Channels Used')
ylabel('Acquisition Time (s)')
title('Acquisition Time for a Single Frequency')

%%
%--------------------------------------------------------------------------
% Get timing for single mux set vs number of datasets acquired
%--------------------------------------------------------------------------
clearvars total_t daq_t ndsets daq_t_curve lb_y_curve
nchs = 3; nfreqs = 1; nskips = 1; navgs = 1;
nfft = 2.^[0:11];
for n = 1:length(nfft)
    nsamps = nfft(n);
    [total_t(n), daq_t(n), ndsets(n)] = get_acquisition_time(nchs,nfreqs,nskips,navgs,nsamps);
end

%--------------------------------------------------------------------------
% Plot
%--------------------------------------------------------------------------
fps_target = 1/30 *ones(size(nfft)); % 30 fps target
daq_t_curve = ndsets.*daq_t;    % acquisition time
lb_y_curve = min(unique([daq_t_curve; fps_target])) *ones(size(nfft)); % lower bound y curve
%--------------------------------------------------------------------------
figure;
plot(nfft,total_t,'k','LineWidth',2); hold on
plot(nfft,daq_t_curve,'b');

% Fill in between curves
fillx = [nfft, fliplr(nfft)];
filly = [daq_t_curve, fliplr(total_t)];
fill(fillx,filly,'b','FaceAlpha',0.5)
filly = [lb_y_curve, fliplr(daq_t_curve)];
fill(fillx,filly,'r','FaceAlpha',0.5)
plot(nfft,fps_target,'k--');

% ylimits = [min(lb_y_curve) max(total_t)]; ylim(ylimits); 
xlim([1 max(nfft)]); grid on
legend('total time','','data tx time','data acq time','30 fps target','Location','northeastoutside')
xlabel('FFT Size (nsamples)')
ylabel('Acquisition Time (s)')
title('Acquisition Time for Tetrapolar Measurements')


return

%--------------------------------------------------------------------------
figure;
semilogy(chs,fps_target,'r--'); hold on
semilogy(chs,t_vs_freq(1,:),'k');
for n = 2:size(t_vs_freq,1)
    semilogy(chs,t_vs_freq(n,:));
end
xlim([1 max(chs)]); grid on
legend('30 fps target','single pattern','Location','northeastoutside')
xlabel('Number of Frequencies Acquired')
ylabel('Acquisition Time (s)')
title('Acquisition Time for Channel Counts 1-64')
%--------------------------------------------------------------------------
% Plot single freq acquisition and freq sweep
figure;
t = tiledlayout('vertical','TileSpacing','tight');
nexttile
loglog(chs,fps_target,'r--'); hold on
loglog(chs,t_vs_freq(:,1),'k');
xlim([1 max(chs)]); grid on
nexttile
plot(chs,fps_target,'r--'); hold on
plot(chs,t_vs_freq(:,1),'k');
xlim([1 max(chs)]); grid on
nexttile
semilogy(chs,fps_target,'r--'); hold on
semilogy(chs,t_vs_freq(:,1),'k');
xlim([1 max(chs)]); grid on

nexttile(1)
legend('30 fps target','single freq','Location','northeastoutside')
xlabel(t,'Number of Channels Used')
ylabel(t,'Acquisition Time (s)')
title(t,'Single Frequency Acquisition Time')

%--------------------------------------------------------------------------
figure;
for n = 1:size(t_vs_freq,2)
    semilogy(chs,t_vs_freq(:,n)); hold on
end
semilogy(chs,fps_target,'r--'); grid on,
xlabel('Number of Channels Used')
ylabel('Acquisition Time (s)')
title('Acquisition Time for 1-64 Frequencies Acquired')

%--------------------------------------------------------------------------
% Get timing per channel count and number of averages
%--------------------------------------------------------------------------
nskips = 1; navgs = 1;
% [total_t, daq_t, ndsets] = get_acquisition_time(nchs,nfreqs,nskips,navgs);
for nchs = 1:64
    for navgs = 1:64
        [total_t, daq_t, ndsets] = get_acquisition_time(nchs,1,nskips,navgs,nsamps);
        t_vs_avgs(nchs,navgs) = total_t;
        daq_t_vs_avgs(nchs,navgs) = daq_t;
        nsets2(nchs,navgs) = ndsets;
        [total_t, daq_t, ndsets] = get_acquisition_time(nchs,64,nskips,navgs,nsamps);
        t_vs_avgs_64f(nchs,navgs) = total_t;
        daq_t_vs_avgs_64f(nchs,navgs) = daq_t;
        nsets3(nchs,navgs) = ndsets;
    end
end
%--------------------------------------------------------------------------
% Plot single freq acquisition and freq sweep
figure; t = tiledlayout('flow','TileSpacing','tight');
nexttile
semilogy(chs,t_vs_freq(:,1)); grid on, hold on
semilogy(chs,t_vs_avgs(:,1));
semilogy(chs,t_vs_avgs(:,64));
semilogy(chs,fps_target,'r--');
title('Single Frequency')
legend('1 freq','1 avg','64 avgs','30 fps','Location','northeastoutside')
nexttile
semilogy(chs,t_vs_freq(:,end)); grid on, hold on
semilogy(chs,t_vs_avgs_64f(:,1));
semilogy(chs,t_vs_avgs_64f(:,64));
semilogy(chs,fps_target,'r--');
legend('64 freqs','1 avg','64 avgs','30 fps','Location','northeastoutside')
title('Frequency Sweep')
xlabel(t,'Number of Channels Used')
ylabel(t,'Acquisition Time (s)')
title(t,'Acquisition Time Per Channel Count')

