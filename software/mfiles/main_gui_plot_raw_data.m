%-----------------------------------------------------------------------
% User Interface Functions: 64-Channel DAQ Rev 2
%       Updated: 10/04/23 for 2023_DAQ_final Vivado project
%-----------------------------------------------------------------------
% Plots for GUI -- called from main_gui App when acquisition is finished
%-----------------------------------------------------------------------

%-----------------------------------------------------------------------
function ret_msg = main_gui_plot_raw_data(plt_handle,iis,vvs,data_iivv)


%-----------------------------------------------------------------------
% Debug mode plot -- plot raw ADC data and full FFT spectrum
%-----------------------------------------------------------------------
% Plot Voltages
% Loop through mux channels
t = tiledlayout(plt_handle,2,2,'TileSpacing','tight','Padding','compact');
% Loop through mux channels
for n_ii = 1:numel(iis)/2
    for n_vv = 1:length(vvs)
        clearvars adc_data
        adc_data = data_iivv(n_ii,n_vv).adc_data; % load adc data struct
        %--------------------------------------------------------------------------
        % Loop through frequencies and plot data
        for fi = 1:length(adc_data)
            for ai = 1:3
                ax = nexttile(t,1); hold(ax,'on')
                plot(ax,adc_data(fi).data_re(:,:,ai)); title(ax,'Raw Data'); xlabel(ax,'sample n')
                ax = nexttile(t,2); hold(ax,'on')
                plot(ax,adc_data(fi).fft_re(:,:,ai),'-.'); title(ax,'Real FFT Spectrum'); xlabel(ax,'bin')
                ax = nexttile(t,3); hold(ax,'on')
                plot(ax,sqrt(adc_data(fi).fft_re(:,:,ai).^2 + adc_data(fi).fft_im(:,:,ai).^2),'-.');
                title(ax,'Magnitude Spectrum'); xlabel(ax,'bin')
                ax = nexttile(t,4); hold(ax,'on')
                plot(ax,adc_data(fi).fft_im(:,:,ai),'-.'); title(ax,'Imaginary FFT Spectrum'); xlabel(ax,'bin')

            end
        end
    end
end
ax = nexttile(t,1); legend(ax,'Location','northwestoutside')
title(t,'Raw ADC and FFT Spectrum Data');
ylabel(t,'ADC Code')

drawnow
ret_msg = 'Finished plotting raw adc and fft spectrum data.';