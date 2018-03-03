
addpath('src', 'src/utils')

disp('Loading sequence')
seq = load_sequence_color('data/sequence','gjbLookAtTarget_', 0, 71, 4, 'jpg');

if exist('data/similarity.mat', 'file') == 2
    disp('Loading similarity from cache')
    load('data/similarity.mat', 'D')
else
    disp('Calculating similarity')
    D = similarity(seq);
    save('data/similarity', 'D')
end

% load('data/flows.mat', 'flows_a')
flows_file = matfile('data/flows.mat');

% FIXME: Ability to choose starting image from input
% prompt = 'Select your starting image [1]: ';
% starting_img = input(prompt);
% 
% if isempty(starting_img)
%     error('No starting image selected')
% end

% TODO: Remove in final version
% test_path = [7     8    17    70    72    71    41    43];
% test_path = [7     8    17];
% test_path = [8 7];
% playback_path(seq, test_path)
% slow_mo_seq = synthesize_slow_motion(flows_file, seq, test_path);

starting_img = 7;
figure
imshow(seq(:, :, :, starting_img))
title('Left-click on the image to draw desired path | Right-click to add final point and finish selection | Backspace to delete previous point')

[x, y] = getline;
close;
user_path = [y, x];

n_pts = size(user_path, 1);
if n_pts < 2
    close all;
    error('You need to select at least 2 points')
end

fprintf("Selected %d points\n", n_pts);

G = to_graph(D);

[seq_idx, pred_pts] = calc_path(G, flows_file, seq, starting_img, user_path, false, true);
[seq_idx_trajectory, pred_trajectory] = calc_path(G, flows_file, seq, starting_img, user_path, true, true);

slow_mo_seq = synthesize_slow_motion(flows_file, seq, seq_idx_trajectory);
slow_mo_seq = draw_path_overlay(slow_mo_seq, pred_trajectory, user_path, 'scale', 0.4);
h = implay(slow_mo_seq, 10);
set(h.Parent, 'Name', 'Slow motion')

% TODO: Replace pred_points
playback_path(seq, seq_idx, 'Without trajectory', pred_pts, user_path);
playback_path(seq, seq_idx_trajectory, 'With trajectory', pred_trajectory, user_path);

disp('Done')

function [sequence_idx, pred_points] = calc_path(G, flows_file, seq, starting_img, user_path, enable_advanced, enable_slow_motion)
n_pts = size(user_path, 1);
sequence_idx = [starting_img];
pred_points = [];
start_point = user_path(1, :);

for i = 2:n_pts
    end_point = user_path(i, :);
    
    [sequence_segment, pred_pts] = best_path(G, flows_file,...
        starting_img, start_point, end_point, seq,...
        'UseTrajectory', enable_advanced);
    
    fprintf("Sequence for line segment: ");
    disp(sequence_segment)
    
    pred_points = [pred_points; pred_pts];
    sequence_idx = [sequence_idx sequence_segment(2:end)];

    start_point = pred_points(end, :);
    starting_img = sequence_segment(end);
end
end