%--------------------------------------------------------------------------
% User Interface Functions: 64-Channel DAQ Rev 2
%--------------------------------------------------------------------------
% Create nskip electrode pairs for iivv's
% Input: chs (array of channels, e.g., first 16 channels would be 1:16)
%        nskips (array of nskip values)
% Output: vvs (matrix of vv pairs)
%--------------------------------------------------------------------------
function [vvs] = create_nskip_pairs(chs,nskips)
%--------------------------------------------------------------------------
% Get channel list
v1(:,1) = chs;      % first electrode in vv pair

%--------------------------------------------------------------------------
% Create vv's - rotate v1 array to create nskip pairs
for n = 1:length(nskips)
    vvpair = [v1 circshift(v1,-1*(nskips(n)+1))];
    if n == 1
        vvs = vvpair;
    else
        vvs = [vvs; vvpair];
    end
end
