%-----------------------------------------------------------------------
% User Interface Functions: 64-Channel DAQ Rev 2
%       Updated: 10/04/23 for 2023_DAQ_final Vivado project
%-----------------------------------------------------------------------
% Plots for GUI -- called from main_gui App when acquisition is finished
%-----------------------------------------------------------------------

%-----------------------------------------------------------------------
function ret_msg = main_gui_plot_electrodes(plt_handle,eit_data)


%-----------------------------------------------------------------------
% EIT data plot
%-----------------------------------------------------------------------
%-----------------------------------------------------------------------
% get voltages per frequency
% for n = 1:length(eit_data)
% if size(eit_data(n).Vmeas,1) == 1 || size(eit_data(n).Vmeas,2) == 1
%     Vmeas(n,:) = eit_data(n).Vmeas;
% else
%     Vmeas(n,:,:) = eit_data(n).Vmeas;
% end
% end
%-----------------------------------------------------------------------
% t = tiledlayout(plt_handle,'flow','TileSpacing','tight','Padding','compact');
% for n = 1:length(eit_data)
%     Vmeas = eit_data(n).Vmeas;
%
%     % plot
%     for i = 1:size(Vmeas,2) % loop through each electrode (column)
%         ax = nexttile(t,i); hold(ax,'on')
%         plot(ax,Vmeas(:,i),'.-'); title(ax,['E' num2str(i)]);
%     end
% end

% ax = nexttile(t,1);
% lgd = legend(ax,'Location','northwestoutside');
% lgd.String = strrep(lgd.String,'data','freq');
% xlabel(t,'Measurement no.')
% ylabel(t,'Voltage (Vpp)')
% title(t,'Measured Voltage per Electrode')

%-----------------------------------------------------------------------
% setup plot
t = tiledlayout(plt_handle,'flow','TileSpacing','tight','Padding','compact');
%-----------------------------------------------------------------------
% Check frequency/dataset dimension
fsig = eit_data(1).f; % frequencies for plot
nfreqs = length(fsig);
ndata = size(eit_data(1).Vmeas);
%-----------------------------------------------------------------------
% get voltages per frequency
if length(eit_data) == nfreqs
    for n = 1:length(eit_data) % loop through frequencies
        Vmeas(n,:,:) = eit_data(n).Vmeas;
    end
    % plot
    for i = 1:size(Vmeas,3) % loop through each electrode (column)
        ax = nexttile(t,i);
        semilogx(ax,fsig,Vmeas(:,:,i),'.-');  hold(ax,'on'); title(ax,['E' num2str(i)]);
    end
    xlabel(t,'Frequency (Hz)')
elseif ndata(3) == nfreqs
    for n = 1:length(eit_data) % loop through datasets (from freq sweep)
        if ndata(1) == 1 || ndata(2) == 1
            Vmeas(:,:) = eit_data(n).Vmeas;
            % plot
            for i = 1:size(Vmeas,1) % loop through each electrode (column)
                ax = nexttile(t,i);
                semilogx(ax,fsig,Vmeas(i,:),'.-');  hold(ax,'on'); title(ax,['E' num2str(i)]);
            end
        else
            
            % plot
            for i = 1:size(eit_data(n).Vmeas,2) % loop through each electrode (column)
                ax = nexttile(t,i);
                Vmeas(:,:) = eit_data(n).Vmeas(:,i,:);
                semilogx(ax,fsig,Vmeas,'.-');  hold(ax,'on'); title(ax,['E' num2str(i)]);
            end
        end

    end
    xlabel(t,'Frequency (Hz)')
elseif ndata(2) == nfreqs
    for n = 1:length(eit_data) % loop through datasets
        Vmeas = eit_data(n).Vmeas;
        % plot
        for i = 1:size(Vmeas,1) % loop through each electrode (column)
            ax = nexttile(t,i);
            semilogx(ax,fsig,Vmeas(i,:,:),'.-');  hold(ax,'on'); title(ax,['E' num2str(i)]);
        end

    end
    xlabel(t,'Frequency (Hz)')
else
    for n = 1:length(eit_data) % loop through datasets
        Vmeas(n,:,:) = eit_data(n).Vmeas;
    end
    % plot
    for i = 1:size(Vmeas,3) % loop through each electrode (column)
        ax = nexttile(t,i);
        plot(ax,Vmeas(:,:,i),'.-');  hold(ax,'on'); title(ax,['E' num2str(i)]);
    end
    xlabel(t,'Measurement No.')
end
if n < 36
    ax = nexttile(t,1);
    lgd = legend(ax,'Location','northwestoutside');
else
    disp([num2str(n) ' legend entries [main_gui_plot_electrodes]'])
end

ylabel(t,'Voltage (Vpp)')
title(t,'Measured Voltage per Electrode')

drawnow
ret_msg = 'Finished plotting measured voltages per electrode.';