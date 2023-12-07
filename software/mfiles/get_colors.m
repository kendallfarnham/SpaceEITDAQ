function pcol = get_colors(n)
% Return plot colors of length n

% MASTER LIST
pcolors = {'#0072BD','#D95319','#EDB120','#7E2F8E','#77AC30','#4DBEEE',...
    '#A2142F','#FF0000','#00FF00','#0000FF','#00FFFF','#FF00FF','#FFFF00'};
ncolors = length(pcolors);

if n <= ncolors
    pcol = pcolors(1:n);
else
    pcol = pcolors;
    pcol(ncolors+1:n) = pcolors(1:n-ncolors);
end

end