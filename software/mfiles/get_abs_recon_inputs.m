%--------------------------------------------------------------------------
% User Interface Functions: 64-Channel DAQ Rev 2
%--------------------------------------------------------------------------
% Get iivvs and Zmeas for EIT recon
% Input: 
% Output: 
%--------------------------------------------------------------------------
function [Z,iivvs] = get_abs_recon_inputs(eit_data,nskips,iis)
%--------------------------------------------------------------------------
% Create iivv's 
%--------------------------------------------------------------------------
if length(eit_data) > 1
    disp('ERROR: data structure has more than one dataset.')
end

vvs = create_nskip_pairs(unique(iis),nskips);   % Get vv pairs

% Build iivv matrix
iivvs = create_iivvs(iis,vvs);
npats = size(iivvs,1);

%--------------------------------------------------------------------------
% Find matching impedance per iivv pattern
%--------------------------------------------------------------------------
Zmeas = eit_data(1).Z;     % Z matrix (niipairs x nelecs x nfreqs)
for n = 1:npats
    % find row for this ii pair        
    nrow = find(ismember(iis,iivvs(n,1:2),'rows'));

    % find associated Z for vv electrodes
    Zvv(n,1,:) = Zmeas(nrow,iivvs(n,3),:);
    Zvv(n,2,:) = Zmeas(nrow,iivvs(n,4),:);
end

Z(:,:) = Zvv(:,1,:) - Zvv(:,2,:);
    