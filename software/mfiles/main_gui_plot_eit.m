%-----------------------------------------------------------------------
% User Interface Functions: 64-Channel DAQ Rev 2
%       Updated: 10/04/23 for 2023_DAQ_final Vivado project
%-----------------------------------------------------------------------
% Plots for GUI -- called from main_gui App when acquisition is finished
%-----------------------------------------------------------------------

%-----------------------------------------------------------------------
function ret_msg = main_gui_plot_eit(plt_handle,eit_data)
%-----------------------------------------------------------------------
% EIT data plot
%-----------------------------------------------------------------------
t = tiledlayout(plt_handle,2,2,'TileSpacing','tight','Padding','compact');
for n = 1:length(eit_data)
    Vmeas = squeeze(eit_data(n).Vmeas);
    Isense = squeeze(eit_data(n).Isense);
    Zmag = squeeze(eit_data(n).Zmag);
    Zphase = squeeze(eit_data(n).Zphase);

    % plot
    if size(Vmeas,3) > 1 % loop through datasets
        for k = 1:size(Vmeas,3)
            ax = nexttile(t,1); hold(ax,'on');
            plot(ax,Vmeas(:,:,k)); title(ax,'Vmeas'); ylabel(ax,'Vpp')
            ax = nexttile(t,2); hold(ax,'on');
            plot(ax,Isense(:,:,k)*1000); title(ax,'Isense'); ylabel(ax,'mA')
            ax = nexttile(t,3); hold(ax,'on');
            plot(ax,Zmag(:,:,k)); title(ax,'Z Magnitude'); ylabel(ax,'Ohms')
            ax = nexttile(t,4); hold(ax,'on');
            plot(ax,Zphase(:,:,k)/pi); title(ax,'Z Phase/\pi'); ylabel(ax,'\theta/\pi')
        end
    else
        % if size(Isense,1) ~= size(Vmeas,1) % transpose
        %     Vmeas = Vmeas';
        %     Isense = Isense';
        %     Zmag = Zmag';
        %     Zphase = Zphase';
        % end
        ax = nexttile(t,1); hold(ax,'on');
        plot(ax,Vmeas); title(ax,'Vmeas'); ylabel(ax,'Vpp')
        ax = nexttile(t,2); hold(ax,'on');
        plot(ax,Isense*1000); title(ax,'Isense'); ylabel(ax,'mA')
        ax = nexttile(t,3); hold(ax,'on');
        plot(ax,Zmag); title(ax,'Z Magnitude'); ylabel(ax,'Ohms')
        ax = nexttile(t,4); hold(ax,'on');
        plot(ax,Zphase/pi); title(ax,'Z Phase/\pi'); ylabel(ax,'\theta/\pi')
    end
end
xlabel(t,'Channel no.')
title(t,'Extracted EIT Data')

drawnow
ret_msg = 'Finished plotting EIT data.';