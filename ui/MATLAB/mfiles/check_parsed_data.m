%--------------------------------------------------------------------------
% User Interface Functions: 64-Channel DAQ Rev 2
%--------------------------------------------------------------------------
% Check parsed ADC data
%--------------------------------------------------------------------------
% Input: avgnum (parsed average numbers from serial data)
%       navgs (number of averages) 
% Output: check (1 if okay, -1 if not)
%--------------------------------------------------------------------------
function [check] = check_parsed_data(avgnum,navgs)

% Get size of vector
len1 = size(avgnum,1);          % dimension 1 should match navgs
seq = 0:navgs-1;                % the sequence we're looking for
avg_adcs(:,:) = mean(avgnum,2); % average across all adcs (nadcs = 3)
avg_set(:) = mean(avg_adcs,2);  % average across all datasets
std_adcs(:,:) = std(avgnum,0,2); % standard deviation across all adcs (nadcs = 3)

%--------------------------------------------------------------------------
% Run checks
if len1 ~= navgs
    fprintf('ERROR: Matrix dimensions do not match. size(x,1) = %d, navgs = %d\n', ...
        len1,navgs);
    check = -1;
elseif any(std_adcs,'all')  % if any are non-zero, something went wrong
    [rw,col,nz] = find(any(std_adcs));
    fprintf(['ERROR: Data between ADCs does not match. %d non-zero standard ' ...
        'deviations, %d frequencies, %d datasets\n'],length(nz),length(unique(rw)), ...
        length(unique(col)));
    check = -1;
elseif ~isequal(seq,avg_set) % sequence is wrong
    fprintf('ERROR: avgnum sequence is incorrect. Correct sequence is 0:%d\n', ...
        navgs-1);
    check = -1;
else
    check = 1;      % all clear
end

