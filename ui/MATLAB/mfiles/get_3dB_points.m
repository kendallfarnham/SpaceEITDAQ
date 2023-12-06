%--------------------------------------------------------------------------
% User Interface Functions: 64-Channel DAQ Rev 2
%--------------------------------------------------------------------------
% Find +/-3dB points at high and low end of freq spectrum
%--------------------------------------------------------------------------
% Input: data (frequency sweep data)
%       lf_hf_only (optional, 1 for low f 3dB pt only, 2 for high f 3dB pt only)
%       is_db (optional, true if data is in dB already, default is false)
% Output: idx_3dB_pts (indices of low/high freq 3dB points)
%       struct_3dB_pts (struct of 3dB points)
%--------------------------------------------------------------------------
function [idx_3dB_pts,struct_3dB_pts] = get_3dB_points(data,lf_hf_only,is_db)
%--------------------------------------------------------------------------
% If data is in volts (default), convert to db
if ~exist('is_db') || ~is_db
    data_dB = 20*log10(data);
else
    data_dB = data;
end
%--------------------------------------------------------------------------
% Check inputs
if ~exist('lf_hf_only') 
    lf_hf_only = 0;
end
%--------------------------------------------------------------------------
% Get midpoint
midpt = round(length(data_dB)/2);
zero_dB = data_dB(midpt);   % get 0 dB point
%--------------------------------------------------------------------------
i = 1; % starting point index
%--------------------------------------------------------------------------
% Find low freq +/-3dB point
if lf_hf_only ~= 2
    for j=midpt:-1:1
        if zero_dB-3 >= data_dB(j)
            idx_3dB_pts(i) = j;
            struct_3dB_pts(1).idx = j;
            struct_3dB_pts(1).val = data(j);
            struct_3dB_pts(1).val_dB = zero_dB-data_dB(j);
            i = i + 1; % increment
            break;
        elseif zero_dB+3 <= data_dB(j)
            idx_3dB_pts(i) = j;
            struct_3dB_pts(1).idx = j;
            struct_3dB_pts(1).val = data(j);
            struct_3dB_pts(1).val_dB = zero_dB-data_dB(j);
            i = i + 1; % increment
            break;
        elseif j == 1 % no match, save to struct but don't increment pt index
            struct_3dB_pts(1).idx = j;
            struct_3dB_pts(1).val = data(j);
            struct_3dB_pts(1).val_dB = zero_dB-data_dB(j);
        end
    end
    if lf_hf_only == 1 && i == 1 % no match, save the first point anyway
        idx_3dB_pts(i) = 1;
    end
end
%--------------------------------------------------------------------------
% Find high freq +/-3dB point
if lf_hf_only ~= 1
for j=midpt:length(data_dB)
    if zero_dB-3 >= data_dB(j)
        idx_3dB_pts(i) = j;
        struct_3dB_pts(2).idx = j;
        struct_3dB_pts(2).val = data(j);
        struct_3dB_pts(2).val_dB = zero_dB-data_dB(j);
        break;
    elseif zero_dB+3 <= data_dB(j)
        idx_3dB_pts(i) = j;
        struct_3dB_pts(2).idx = j;
        struct_3dB_pts(2).val = data(j);
        struct_3dB_pts(2).val_dB = zero_dB-data_dB(j);
        break;
    else
        idx_3dB_pts(i) = j;
        struct_3dB_pts(2).idx = j;
        struct_3dB_pts(2).val = data(j);
        struct_3dB_pts(2).val_dB = zero_dB-data_dB(j);
    end
end
end
%         semilogx(minus3dB.f,data(minus3dB.idx),'k*')
%--------------------------------------------------------------------------

end