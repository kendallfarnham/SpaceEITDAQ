%-----------------------------------------------------------------------
% User Interface Functions: 64-Channel DAQ Rev 2
%       Updated: 10/04/23 for 2023_DAQ_final Vivado project
%-----------------------------------------------------------------------
% Plots for GUI -- called from main_gui App when acquisition is finished
%-----------------------------------------------------------------------

%-----------------------------------------------------------------------
function ret_msg = main_gui_plot_freqsweep(plt_handle,adc_data_struct)


%-----------------------------------------------------------------------
% Voltage plot
%-----------------------------------------------------------------------
% % Plot Voltages vs frequency
% if exist('adc_data_struct(1,1).fsigs','var')
%     fsigs = adc_data_struct(1,1).fsigs; % frequencies
% else
%     fsigs = 1:length(adc_data_struct(1,1).vpp_i); % count indices
% end
fsigs = adc_data_struct(1,1).fsigs; % frequencies
% Loop through mux channels
t = tiledlayout(plt_handle,2,2,'TileSpacing','tight','Padding','compact');
for n_ii = 1:size(adc_data_struct,1)
    for n_vv = 1:size(adc_data_struct,2)
        ax = nexttile(t,1);
        semilogx(ax,fsigs,adc_data_struct(n_ii,n_vv).vpp_i); hold(ax,'on');
        title(ax,'V(Isense)')
        ax = nexttile(t,2);
        semilogx(ax,fsigs,adc_data_struct(n_ii,n_vv).vpp_v1); hold(ax,'on');
        title(ax,'V(Vpickup1)')
        ax = nexttile(t,3);
        semilogx(ax,fsigs,adc_data_struct(n_ii,n_vv).vpp_v2); hold(ax,'on');
        title(ax,'V(Vpickup2)')
        ax = nexttile(t,4);
        semilogx(ax,fsigs,adc_data_struct(n_ii,n_vv).vdc_i,'m'); hold(ax,'on');
        semilogx(ax,fsigs,adc_data_struct(n_ii,n_vv).vdc_v1,'b')
        semilogx(ax,fsigs,adc_data_struct(n_ii,n_vv).vdc_v2,'g');
        legend(ax,'Isense','V1','V2');
        title(ax,'DC Offset')
    end
end
ax = nexttile(t,1); legend(ax,'Location','northwestoutside')
title(t,'Frequency Sweep (Voltages)');
xlabel(t,'Frequency (Hz)'); ylabel(t,'Vpp')

drawnow
ret_msg = 'Finished plotting frequency sweep data.';