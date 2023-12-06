%--------------------------------------------------------------------------
% User Interface Functions: 64-Channel DAQ Rev 2
%--------------------------------------------------------------------------
% Create iivv's from electrode pairs
% Input: vsource (Vs+ channels)
%        vsink (Vs- channels, 0 if disabled)
%        vpickup (V1/V2 channels)
%        nskips (nskips for ii (vs+/-) list)
% Output: iis (vsource/vsink electrode pairs
%        vvs (vmeas electrode pairs)
%--------------------------------------------------------------------------
function [iis,vvs] = get_ii_vv_channels(vsource,vsink,vpickup,nskips)
%--------------------------------------------------------------------------
% Create ii pairs using nskips or vsource/vsink channels
if exist('nskips','var') && ~isempty('nskips')
    iis = create_nskip_pairs(vsource,nskips);
else
    for n = 1:length(vsource)
        for m = 1:length(vsink)
            ch_pair = [vsource(n) vsink(m)];
            if n*m == 1     % first pair
                iis = ch_pair;
            else            % append
                iis = [iis; ch_pair];
            end

        end
    end
end
%--------------------------------------------------------------------------
% Create list of vpickup channels (divide by 2 for dual-channel vpickup)
vvs = unique(round(vpickup/2)); % channels in use, divided by 2 (vpickup channels are index 1:32)
