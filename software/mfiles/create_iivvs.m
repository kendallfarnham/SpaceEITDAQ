%--------------------------------------------------------------------------
% User Interface Functions: 64-Channel DAQ Rev 2
%--------------------------------------------------------------------------
% Create iivv's from electrode pairs
% Input: iis (vsource/vsink electrode pairs)
%        vvs (vmeas electrode pairs)
%        keep_dups (optional) (keep duplicate patterns, default is to remove)
% Output: iivvs (matrix of full iivv set)
%--------------------------------------------------------------------------
function [iivvs] = create_iivvs(iis,vvs,keep_dups)
%--------------------------------------------------------------------------
nvvs = size(vvs,1);     % number of vv pairs
%--------------------------------------------------------------------------
% Loop through ii pairs and add vvs
for n = 1:numel(iis)/2
    iiset = repmat(iis(n,:),nvvs,1);     % create ii set
    iivvset = [iiset vvs];

    % build matrix
    if n == 1
        iivvs = iivvset;
    else
        iivvs = [iivvs; iivvset];
    end
end

if exist('keep_dups','var') && keep_dups == 1
    % Return iivvs, keep duplicates
else
    % Remove sets with duplicate source/meas electrodes
    keepi = ones(size(iivvs,1),1);  % keep indices
    for n = 1:size(iivvs,1)
        if length(unique(iivvs(n,:))) < 4
            keepi(n) = 0;           % remove pattern
        end
    end

    iivvs = iivvs(keepi == 1,:);
end
end
