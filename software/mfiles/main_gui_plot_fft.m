%-----------------------------------------------------------------------
% User Interface Functions: 64-Channel DAQ Rev 2
%       Updated: 10/04/23 for 2023_DAQ_final Vivado project
%-----------------------------------------------------------------------
% Plots for GUI -- called from main_gui App when acquisition is finished
%-----------------------------------------------------------------------

%-----------------------------------------------------------------------
function ret_msg = main_gui_plot_fft(plt_handle,iis,vvs,data_iivv)


%-----------------------------------------------------------------------
% plot re/im/mag/phase data from signal bins
%-----------------------------------------------------------------------
t = tiledlayout(plt_handle,2,4,'TileSpacing','tight','Padding','compact');
clrs = {'m','b','g'}; % line colors per adc
% Loop through mux channels
for n_ii = 1:numel(iis)/2
    for n_vv = 1:length(vvs)
        clearvars adc_data
        adc_data = data_iivv(n_ii,n_vv).adc_data;
        %--------------------------------------------------------------------------
        % Loop through frequencies and plot data
        for fi = 1:length(adc_data)
            for ai = 1:3
                ax = nexttile(t,1); hold(ax,'on')
                plot(ax,real(adc_data(fi).fft_k1(:,ai)),'Color',clrs{ai}); title(ax,'Real FFT k1');
                ax = nexttile(t,2); hold(ax,'on')
                plot(ax,imag(adc_data(fi).fft_k1(:,ai)),'Color',clrs{ai}); title(ax,'Imag FFT k1');
                ax = nexttile(t,3); hold(ax,'on')
                plot(ax,abs(adc_data(fi).fft_k1(:,ai)),'Color',clrs{ai}); title(ax,'Mag FFT k1');
                ax = nexttile(t,4); hold(ax,'on')
                plot(ax,unwrap(angle(adc_data(fi).fft_k1(:,ai)))/pi,'Color',clrs{ai}); title(ax,'\Theta/\pi FFT k1');
                ax = nexttile(t,5); hold(ax,'on')
                plot(ax,real(adc_data(fi).fft_k2(:,ai)),'Color',clrs{ai}); title(ax,'Real FFT N-k1');
                ax = nexttile(t,6); hold(ax,'on')
                plot(ax,imag(adc_data(fi).fft_k2(:,ai)),'Color',clrs{ai}); title(ax,'Imag FFT N-k1');
                ax = nexttile(t,7); hold(ax,'on')
                plot(ax,abs(adc_data(fi).fft_k2(:,ai)),'Color',clrs{ai}); title(ax,'Mag FFT N-k1');
                ax = nexttile(t,8); hold(ax,'on')
                plot(ax,unwrap(angle(adc_data(fi).fft_k2(:,ai)))/pi,'Color',clrs{ai}); title(ax,'\Theta/\pi FFT N-k1');

            end
            id1 = 3*(fi-1)+1; % index of legend string
            lgd_str(id1:id1+2) = {['Isense f' num2str(fi)], ['Vpickup 1 f' num2str(fi)], ['Vpickup 2 f' num2str(fi)]};
        end
    end
end
ax = nexttile(t,1); legend(ax,lgd_str,'Location','northwestoutside')
xlabel(t,'sample n')
title(t,'Parsed FFT Signal Bin Data')

drawnow
ret_msg = 'Finished plotting FFT data.';