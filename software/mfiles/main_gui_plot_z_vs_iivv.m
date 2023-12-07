%-----------------------------------------------------------------------
% User Interface Functions: 64-Channel DAQ Rev 2
%       Updated: 10/04/23 for 2023_DAQ_final Vivado project
%-----------------------------------------------------------------------
% Plots for GUI -- called from main_gui App when acquisition is finished
%-----------------------------------------------------------------------

%-----------------------------------------------------------------------
function ret_msg = main_gui_plot_z_vs_iivv(plt_handle,eit_data,nskips)
%--------------------------------------------------------------------------
% Set nskips for iivv creation
%-----------------------------------------------------------------------
% Plot Z vs iivv pattern
%-----------------------------------------------------------------------
t = tiledlayout(plt_handle,2,2,'TileSpacing','tight','Padding','compact');

for ki = 1:length(eit_data)
    [Z,~,~] = get_recon_inputs(eit_data(ki),nskips);
    for fi = 1:size(Z,2)
        ax = nexttile(t,1); hold(ax,'on'); grid(ax,'on')
        plot(ax,real(Z(:,fi)),'.-','MarkerEdgeColor','r'); 
        title(ax,'Resistance (R)')
        ax = nexttile(t,2); hold(ax,'on'); grid(ax,'on')
        plot(ax,imag(Z(:,fi)),'.-','MarkerEdgeColor','r'); 
        title(ax,'Reactance (X)')
        ax = nexttile(t,3); hold(ax,'on'); grid(ax,'on')
        plot(ax,abs(Z(:,fi)),'.-','MarkerEdgeColor','r'); 
        title(ax,'Impedance Magnitude (|Z|)')
        ax = nexttile(t,4); hold(ax,'on'); grid(ax,'on')
        plot(ax,unwrap(angle(Z(:,fi)))/pi,'.-','MarkerEdgeColor','r'); 
        title(ax,'Impedance Phase (\angleZ)'); ylabel(ax,'\theta/\pi')
    end
end

xlabel(t,'iivv pattern number')
ylabel(t,'Ohms')
title(t,'Measured Impedance (Z = R + jX)')
if ki > 1
ax = nexttile(t,1);
lgd = legend(ax,'Location','northwestoutside');
lgd.String = strrep(lgd.String,'data','freq');
end


drawnow
ret_msg = 'Finished plotting Z vs iivv pattern data.';