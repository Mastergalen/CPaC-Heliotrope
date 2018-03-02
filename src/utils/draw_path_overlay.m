function [ seq ] = draw_path_overlay( seq, pred_pts, target_pts )
%DRAW_PATH_OVERLAY Edits sequence to draw overlay of user path and
%predicted path
[~, ~, ~, len] = size(seq);

disp('Drawing path overlay')

pred_pts = swap_axes(pred_pts);
target_pts = swap_axes(target_pts);

pred_pts = pred_pts';
pred_line = [target_pts(1,:) pred_pts(:)'];

target_line = target_pts';
target_line = target_line(:)';
line_param = {pred_line, target_line};
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