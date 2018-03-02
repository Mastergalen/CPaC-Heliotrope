
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
imshow(seq(:, :, :, starting_img))
title('Left-click on the image to draw desired path')
disp('Double-click to finish drawing')

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

new_sequence = [starting_img];
new_sequence_trajectory = [starting_img];
pred_points = [];
pred_points_adv = [];
for i = 2:n_pts
    start_point = user_path(i-1, :);
    end_point = user_path(i, :);
    [simple_sequence_order, pred_pts] = best_path(G, flows_file,...
        starting_img, start_point, end_point, seq);
    pred_points = [pred_points; pred_pts];
    fprintf("Simple Sequence: ");
    disp(simple_sequence_order)
    new_sequence = [new_sequence simple_sequence_order(2:end)];
    
    [sequence_order,  pred_pts_adv] = best_path_advanced(...
        G, flows_file, starting_img, start_point, end_point, seq);
    pred_points_adv = [pred_points_adv; pred_pts_adv];
    fprintf("Sequence: ");
    disp(sequence_order)
    new_sequence_trajectory = [new_sequence_trajectory sequence_order(2:end)];

    starting_img = sequence_order(end);
end

slow_mo_seq = synthesize_slow_motion(flows_file, seq, new_sequence_trajectory);
slow_mo_seq = draw_path_overlay(slow_mo_seq, pred_points_adv, user_path);
h = implay(slow_mo_seq, 10);
set(h.Parent, 'Name', 'Slow motion')

% TODO: Replace pred_points
playback_path(seq, new_sequence, 'Without trajectory', pred_points, user_path);
playback_path(seq, new_sequence_trajectory, 'With trajectory', pred_points_adv, user_path);

disp('Done')