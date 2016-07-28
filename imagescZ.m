function imagescZ(kernel)
%
%imagescZ - function to make imagesc-plot with z-scale adjusted so midpoint==0
%   usage:   imagescZ(array)
%
%   if array is 1-d, reshapes as square image

% to do:
%   option to make midpoint=127.5


yMax = max(max(kernel));  yMin = min(min(kernel));
yMx = max([abs(yMax) abs(yMin)]);

if min(size(kernel))==1         % handle images reshaped as 1-d
    siz = sqrt(length(kernel));
    if ~(siz==round(siz))
        error('not a square image array !');
    end
    kernel = reshape(kernel,siz,siz);
end

imagesc(kernel,[-yMx yMx]);

clear yMax yMx;

return

