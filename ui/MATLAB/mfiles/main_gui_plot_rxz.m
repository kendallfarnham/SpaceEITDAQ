%-----------------------------------------------------------------------
% User Interface Functions: 64-Channel DAQ Rev 2
%       Updated: 10/04/23 for 2023_DAQ_final Vivado project
%-----------------------------------------------------------------------
% Plots for GUI -- called from main_gui App when acquisition is finished
%-----------------------------------------------------------------------

%-----------------------------------------------------------------------
function ret_msg = main_gui_plot_rxz(plt_handle,eit_data)


%-----------------------------------------------------------------------
% EIT data plot
%-----------------------------------------------------------------------
t = tiledlayout(plt_handle,3,2,'TileSpacing','tight','Padding','compact');
for n = 1:length(eit_data)
    % R = eit_data(n).R;
    % X = eit_data(n).X;
    % Z = eit_data(n).Z;
    Zmag = eit_data(n).Zmag;
    Zphase = eit_data(n).Zphase;
    Vpickup1 = eit_data(n).Vpickup1;
    Vpickup2 = eit_data(n).Vpickup2;
    Isense = eit_data(n).Isense;
    Rload = abs(Vpickup1 - Vpickup2)./Isense;
    % R = Zmag.*cos(Zphase);
    % X = Zmag.*sin(Zphase);
    R = Zmag.*cos(Zphase-Zphase(1)); % get relative phase
    X = Zmag.*sin(Zphase-Zphase(1)); % get relative phase

    % plot
    if size(Zmag,3) > 1 % loop through datasets
        for k = 1:size(Zmag,3)
            ax = nexttile(t,1); hold(ax,'on'); grid(ax,'on')
            plot(ax,R(:,:,k)); title(ax,'Resistance'); ylabel(ax,'Ohms'),
            ax = nexttile(t,2); hold(ax,'on'); grid(ax,'on')
            plot(ax,X(:,:,k)); title(ax,'Reactance'); ylabel(ax,'Ohms')
            ax = nexttile(t,3); hold(ax,'on'); grid(ax,'on')
            plot(ax,Zmag(:,:,k)); title(ax,'Z Magnitude'); ylabel(ax,'|Z|')
            ax = nexttile(t,4); hold(ax,'on'); grid(ax,'on')
            plot(ax,Zphase(:,:,k)/pi); title(ax,'Z Phase/\pi'); ylabel(ax,'\theta/\pi')
            ax = nexttile(t,5,[1 2]); hold(ax,'on'); grid(ax,'on')
            plot(ax,Rload(:,:,k),'o'); title(ax,'Rload = |V1-V2|/Isense'); ylabel(ax,'Ohms')
        end
    else
        ax = nexttile(t,1); hold(ax,'on'); grid(ax,'on')
        plot(ax,R); title(ax,'Resistance'); ylabel(ax,'Ohms'),
        ax = nexttile(t,2); hold(ax,'on'); grid(ax,'on')
        plot(ax,X); title(ax,'Reactance'); ylabel(ax,'Ohms')
        ax = nexttile(t,3); hold(ax,'on'); grid(ax,'on')
        plot(ax,Zmag); title(ax,'Z Magnitude'); ylabel(ax,'|Z|')
        ax = nexttile(t,4); hold(ax,'on'); grid(ax,'on')
        plot(ax,Zphase/pi); title(ax,'Z Phase/\pi'); ylabel(ax,'\theta/\pi')
        ax = nexttile(t,5,[1 2]); hold(ax,'on'); grid(ax,'on')
        plot(ax,Rload,'o'); title(ax,'Rload = |V1-V2|/Isense'); ylabel(ax,'Ohms')
    end

    % plot

end
if n < 50
    ax = nexttile(t,2);
    lgd = legend(ax,'Location','northeastoutside');
    % lgd.String = strrep(lgd.String,'data','freq');
end
xlabel(t,'Channel no.')
title(t,'Extracted Impedance Data')

drawnow
ret_msg = 'Finished plotting impedance data.';