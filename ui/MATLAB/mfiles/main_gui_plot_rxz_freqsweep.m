%-----------------------------------------------------------------------
% User Interface Functions: 64-Channel DAQ Rev 2
%       Updated: 10/04/23 for 2023_DAQ_final Vivado project
%-----------------------------------------------------------------------
% Plots for GUI -- called from main_gui App when acquisition is finished
%-----------------------------------------------------------------------

%-----------------------------------------------------------------------
function ret_msg = main_gui_plot_rxz_freqsweep(plt_handle,eit_data)


%-----------------------------------------------------------------------
% EIT data plot
%-----------------------------------------------------------------------
fsigs = eit_data(1,1).f;        % get frequencies

% combine data per frequency
if length(eit_data) == 1
    Zmag(:,:) = eit_data(1).Zmag;
    Zphase(:,:) = eit_data(1).Zphase;

    Zmag = Zmag';       % transpose to get freq in first dim, elec in second
    Zphase = Zphase';
    
else
for n = 1:length(eit_data)
    % R(n,:) = eit_data(n).R;
    % X(n,:) = eit_data(n).X;
    Zmag(n,:) = eit_data(n).Zmag;
    Zphase(n,:) = eit_data(n).Zphase;
end
end

% R = Zmag.*cos(Zphase);
% X = Zmag.*sin(Zphase);
R = Zmag.*cos(Zphase-Zphase(:,1)); % get relative phase
X = Zmag.*sin(Zphase-Zphase(:,1)); % get relative phase
%-----------------------------------------------------------------------
% plot semilog
t = tiledlayout(plt_handle,2,2,'TileSpacing','tight','Padding','compact');

for m = 1:size(R,2)
    ax = nexttile(t,1);
    semilogx(ax,fsigs,R(:,m)); hold(ax,'on');
    title(ax,'Resistance')
    ax = nexttile(t,2);
    semilogx(ax,fsigs,X(:,m)); hold(ax,'on');
    title(ax,'Reactance')
    legend(ax,'Location','northeastoutside')
    ax = nexttile(t,3);
    semilogx(ax,fsigs,Zmag(:,m)); hold(ax,'on');
    title(ax,'Z Magnitude'); ylabel(ax,'|Z|')
    ax = nexttile(t,4);
    semilogx(ax,fsigs,Zphase(:,m)/pi); hold(ax,'on');
    title(ax,'Z Phase/\pi'); ylabel(ax,'\theta/\pi')
end


xlabel(t,'Frequency (Hz)'); ylabel(t,'Ohms'),
title(t,'Extracted Impedance Data')

drawnow
ret_msg = 'Finished plotting impedance data.';