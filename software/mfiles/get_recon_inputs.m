%--------------------------------------------------------------------------
% User Interface Functions: 64-Channel DAQ Rev 2
%--------------------------------------------------------------------------
% Get iivvs and Zmeas for EIT recon
% Inputs:   eit_data (data struct from extract_eit_data)
%           nskips (list of nskips for vv's)
%           ii_pairs (optional) (list of ii pairs)
%           vv_chs (optional) (list of vpickup channels)
% Outputs:  Z (array of complex impedances)
%           iivvs (matrix of iivv patterns)
%           f (frequencies)
%--------------------------------------------------------------------------
function [Z,iivvs,f] = get_recon_inputs(eit_data,nskips,ii_pairs,vv_chs)
%-----------------------------------------------------------------------
% Check optional inputs (ii pairs and vpickup channel list)
%-----------------------------------------------------------------------
if ~exist('ii_pairs','var')
    ii_pairs = eit_data(1).iis;  % Get ii pairs used in acquisition
end
if ~exist('vv_chs','var')
    d4 = find(size(eit_data(1).iivv) == 4,1,'last'); % find dimension with vs+/- v1/v2 chs
    if d4 == 3
        vv_chs = unique(eit_data(1).iivv(:,:,3:4));
    else
        vv_chs = unique(eit_data(1).iivv(:,3:4));
    end
end
%--------------------------------------------------------------------------
% Create iivv's for data extraction (use index of channel)
%--------------------------------------------------------------------------
vv_chs = unique(vv_chs);    % make sure it's a single column array
vvs = create_nskip_pairs(1:length(vv_chs),nskips);    % Get vv pairs using indices
iivv_int = create_iivvs(ii_pairs,vvs);      % Build iivv matrix (internal)
%--------------------------------------------------------------------------
% Create iivv's associated with actual voltage channel number
%--------------------------------------------------------------------------
vvs = create_nskip_pairs(vv_chs,nskips);    % Get vv pairs
iivvs = create_iivvs(ii_pairs,vvs);         % Build iivv matrix (return)

%--------------------------------------------------------------------------
% Find matching impedance per iivv pattern
%--------------------------------------------------------------------------
iis = eit_data(1).iis;      % Get ii pairs used in acquisition
f = eit_data(1).f;          % list of frequencies acquired
Zmeas = eit_data(1).Zmag;      % Z matrix (niipairs x nelecs x nfreqs)


% Done if eit_data structure is 1 element

%--------------------------------------------------------------------------
% Otherwise, Loop through eit_data structures
%--------------------------------------------------------------------------
if length(eit_data) > 1
    if size(Z,1) > 1 && size(Z,2) > 1
        Z_2d = 1;    % 2 dimensional data
    else
        Z_2d = 0;    % array
    end

    for k = 1:length(eit_data)  % loop through structs
        Zmeas = eit_data(k).Zmag;
        if Z_2d      % Z vs freq, struct split by datasets
            Z(:,:,k) = find_z_array(Zmeas,iivv_int,iis);
        else
            Z(:,k) = find_z_array(Zmeas,iivv_int,iis);
        end
    end
else
    Z = find_z_array(Zmeas,iivv_int,iis);
end
%--------------------------------------------------------------------------
% end of main function

%--------------------------------------------------------------------------
% Internal function: Find matching impedance per iivv pattern
%--------------------------------------------------------------------------
function Z = find_z_array(Zmeas,iivvs,iis)
for n = 1:size(iivvs,1)

    % find associated Z for vv electrodes
    if numel(iis) > 2 % more than one pair
    % find row for this ii pair
        nrow = find(ismember(iis,iivvs(n,1:2),'rows'));
        Zvv(n,1,:) = Zmeas(nrow,iivvs(n,3),:);
        Zvv(n,2,:) = Zmeas(nrow,iivvs(n,4),:);
    else
        Zvv(n,1,:) = Zmeas(iivvs(n,3),:);
        Zvv(n,2,:) = Zmeas(iivvs(n,4),:);
    end
end
Z(:,:) = abs(Zvv(:,1,:)) - abs(Zvv(:,2,:));
end
%--------------------------------------------------------------------------
end
%--------------------------------------------------------------------------

