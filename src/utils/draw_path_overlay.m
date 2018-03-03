function [ seq ] = draw_path_overlay( seq, pred_pts, target_pts, varargin )
%DRAW_PATH_OVERLAY Edits sequence to draw overlay of user path and
%predicted path

defaultScaleFactor = 1;

p = inputParser;
validScalarPosNum = @(x) isnumeric(x) && isscalar(x) && (x > 0);
addOptional(p, 'scale', defaultScaleFactor, validScalarPosNum);
parse(p, varargin{:});

[~, ~, ~, len] = size(seq);

disp('Drawing path overlay')

pred_pts = swap_axes(pred_pts);
target_pts = swap_axes(target_pts);

pred_pts = pred_pts';
pred_line = [target_pts(1,:) pred_pts(:)'];

target_line = target_pts';
target_line = target_line(:)';
line_param = {pred_line * p.Results.scale, target_line * p.Results.scale};
for t = 1:len
    seq(:, :, :, t) = insertShape(seq(:, :, :, t),...
        'Line', line_param, ...
        'Color', {'red', 'green'});
end
end

function coordinates = swap_axes(coordinates)
    tmp = coordinates(:, 1);
    coordinates(:, 1) = coordinates(:, 2);
    coordinates(:, 2) = tmp; 
end