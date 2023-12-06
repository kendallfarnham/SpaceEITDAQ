%--------------------------------------------------------------------------
% Get indices out of bound
% Use to remove patterns where Z is outside of threshhold
%--------------------------------------------------------------------------

function [idx_rm] = get_oob_indices(d, dmin, dmax, rm_zeros)
    idx_rm = find(abs(d) < dmin);  
    idx_rm = [idx_rm; find(abs(d) > dmax)];
    if rm_zeros
        idx_rm = [idx_rm; find(abs(d) == 0)];
    end
end