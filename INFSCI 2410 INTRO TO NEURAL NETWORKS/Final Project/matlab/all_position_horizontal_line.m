% 2015-04-29 Leon Lai <Leon.Lai@pitt.edu>
%
% This function generates all unique images containing a horizontal line of
% specified stroke width and color. Warning: this function does not verify
% that the specified stroke width remains under the minimum canvas dimension.
%
% Parameters:
%   m:
%     height of image.
%   n:
%     width of image.
%   width:
%     stroke width.
%   color:
%     value between 0 and 1 where 0 is black and 1 is white.
%   colmode:
%     if true, instead of returning a cell array, returns a matrix where each
%     column is an image after reshape.
%
% Returns:
%   C:
%     cell array or matrix of image data.
%
function C = all_position_horizontal_line (m, n, width, color, colmode)
Y = m - (width - 1) ;
C = cell (1, Y) ;
k = 1 ;
for y = 1 : Y
  C {k} = zeros (m, n) ;
  for j = y : y + (width - 1)
    C {k} (j, :) = color;
  end
  k = k + 1 ;
end
if colmode
  C = cell2mat (cellfun (@ (x) reshape (x, m * n, 1), C, 'un', 0)) ;
end
