%-----------------------------------------------------------------------
% User Interface Functions: 64-Channel DAQ Rev 2
%       Updated: 10/04/23 for 2023_DAQ_final Vivado project
%-----------------------------------------------------------------------
% Plots for GUI -- called from main_gui App when acquisition is finished
%-----------------------------------------------------------------------

%-----------------------------------------------------------------------
function ret_msg = main_gui_plot_voltage(plt_handle,iis,vvs,adc_data_struct)


%-----------------------------------------------------------------------
% Voltage plot
%-----------------------------------------------------------------------
% Plot Voltages
% Loop through mux channels
t = tiledlayout(plt_handle,'flow','TileSpacing','tight','Padding','compact');
for n_ii = 1:numel(iis)/2
    % get all vv patterns from ii set
    xdata1 = adc_data_struct(n_ii,1).vpp_i; % get first vv pattern
    xdata2 = adc_data_struct(n_ii,1).vpp_v1;
    xdata3 = adc_data_struct(n_ii,1).vpp_v2;
    for n_vv = 2:length(vvs)
        xdata1 = [xdata1; adc_data_struct(n_ii,n_vv).vpp_i];
        xdata2 = [xdata2; adc_data_struct(n_ii,n_vv).vpp_v1];
        xdata3 = [xdata3; adc_data_struct(n_ii,n_vv).vpp_v2];
    end

    ax = nexttile(t);
    plot(ax,xdata1,'m','DisplayName','Isense'); hold(ax,'on');
    plot(ax,xdata2,'b','DisplayName','Vpickup 1');
    plot(ax,xdata3,'g','DisplayName','Vpickup 2');

    title(ax,num2str(iis(n_ii,:)))


end
% lgd_str = {'Isense f1','Isense f2','Vpickup 1 f1','Vpickup 1 f2','Voickup 2 f1','Voickup 2 f2'}
ax = nexttile(t,1); legend(ax,'Location','northwestoutside')
title(t,'Voltages per Vs+/Vs- pair');
xlabel(t,'Measurement no.'); ylabel(t,'Vpp')


drawnow
ret_msg = 'Finished plotting voltage data.';