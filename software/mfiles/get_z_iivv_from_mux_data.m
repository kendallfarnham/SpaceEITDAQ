%-----------------------------------------------------------------------
% User Interface Functions: 64-Channel DAQ Rev 2
%       Updated: 11/09/23 for 2023_DAQ_final Vivado project
%-----------------------------------------------------------------------
% Create iivvs and Z's from extracted eit_data struct
%-----------------------------------------------------------------------
% Inputs:   eit_data (data struct from extract_eit_data)
%           nskips (list of nskips for vv's)
%           ii_pairs (optional) (list of ii pairs)
%           vv_chs (optional) (list of vpickup channels)
%           keep_dups (optional) (keep duplicate patterns, default is to remove)
% Outputs:  Z (array of complex impedances)
%           iivvs (matrix of iivv patterns)
%           f (frequencies)
%--------------------------------------------------------------------------
function [Zmag,Zphase,iivvs,f] = get_z_iivv_from_mux_data(eit_data,nskips,ii_pairs,vv_chs,keep_dups)
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
if ~exist('keep_dups','var')
    keep_dups = 0;  % Remove duplicate iivv patterns
end

%--------------------------------------------------------------------------
% Create iivv's associated with voltage channels (use actual channel numbers)
%       and data extraction (use index of channel)
%--------------------------------------------------------------------------
vv_chs = unique(vv_chs);    % make sure it's a single column array
if numel(vv_chs) > 2
    vvs = create_nskip_pairs(vv_chs,nskips);  % Get vv pairs
    vvs_idx = create_nskip_pairs(1:length(vv_chs),nskips);  % pairs using indices in matrix
else
    vvs = vv_chs;       % if it's only one pair, no skip pattern
    vvs_idx = 1:2;      % indices are 1,2
end
iivvs = create_iivvs(ii_pairs,vvs,1);           % Build iivv matrix (return)
iivv_int = create_iivvs(ii_pairs,vvs_idx,1);    % Build iivv matrix (internal)
f = eit_data(1).f;          % list of frequencies acquired (for return)

%--------------------------------------------------------------------------
% Remove duplicate patterns if selected
if exist('keep_dups','var') && keep_dups == 1
    keepi = ones(size(iivvs,1),1);  % Keep duplicate patterns
else
    % Remove sets with duplicate source/meas electrodes
    keepi = ones(size(iivvs,1),1);  % keep indices
    for n = 1:size(iivvs,1)
        if length(unique(iivvs(n,:))) < 4
            keepi(n) = 0;           % remove pattern
        end
    end
end
iivvs = iivvs(keepi == 1,:);
iivv_int = iivv_int(keepi == 1,:);


%--------------------------------------------------------------------------
% Loop through eit_data structures
%--------------------------------------------------------------------------
if length(eit_data) == 1
    Zmag = find_z_array(eit_data(1).Zmag,iivv_int,ii_pairs);
    Zphase = find_z_array(eit_data(1).Zphase,iivv_int,ii_pairs);
else
    Zmat = eit_data(1).Zmag;      % Z matrix (niipairs x nelecs x nfreqs)
    for k = 1:length(eit_data)  % loop through structs
        if size(Zmat,1) > 1 && size(Zmat,2) > 1
            Zmag_mat(:,:,k) = eit_data(k).Zmag;
            Zphase_mat(:,:,k) = eit_data(k).Zphase;
        else
            Zmag_mat(:,k) = eit_data(k).Zmag;
            Zphase_mat(:,:,k) = eit_data(k).Zphase;
        end
    end
    Zmag = find_z_array(Zmag_mat,iivv_int,iis);
    Zphase = find_z_array(Zphase_mat,iivv_int,iis);
end
%--------------------------------------------------------------------------
% end of main function

%--------------------------------------------------------------------------
% Internal function: Find matching impedance per iivv pattern
%--------------------------------------------------------------------------
    function Z = find_z_array(Zphase,iivvs,iis)
        for n = 1:size(iivvs,1)

            % find associated Z for vv electrodes
            if numel(iis) > 2
                % find row for this ii pair
                nrow = find(ismember(iis,iivvs(n,1:2),'rows'));
                Z1(n,:) = Zphase(nrow,iivvs(n,3),:);
                Z2(n,:) = Zphase(nrow,iivvs(n,4),:);
            elseif size(Zphase,1) == 1
                Z1(n,:) = Zphase(1,iivvs(n,3),:);
                Z2(n,:) = Zphase(1,iivvs(n,4),:);
            else
                Z1(n,:) = Zphase(iivvs(n,3),:);
                Z2(n,:) = Zphase(iivvs(n,4),:);
            end
        end
        Z = Z1 - Z2;
    end
%--------------------------------------------------------------------------
end
%--------------------------------------------------------------------------

