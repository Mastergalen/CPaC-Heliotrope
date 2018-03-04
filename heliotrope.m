
addpath('src', 'src/utils')

% Select which dataset to use
% dataset = 'trump';
dataset = 'gabe';

fprintf('Loading %s sequence\n', dataset)

if strcmp(dataset, 'gabe')
    starting_img = 9;
    seq = load_sequence_color('data/gabe','gjbLookAtTarget_', 0, 71, 4, 'jpg');
elseif strcmp(dataset, 'trump')
    starting_img = 10;
    seq = load_sequence_color('data/trump','trump_', 0, 46, 4, 'png');
end

sim_file_name = sprintf('data/%s_similarity.mat', dataset);
if exist(sim_file_name, 'file') == 2
    disp('Loading similarity from cache')
    load(sim_file_name, 'D')
else
    disp('Calculating similarity')
    D = similarity(seq);
    save(sprintf('data/%s_similarity', dataset), 'D')
end

flows_file = matfile(sprintf('data/%s_flows.mat', dataset));

prompt = sprintf('Enter your starting image [%d]: ', starting_img);
selection = input(prompt);
 
if ~isempty(selection)
    starting_img = selection;
end

fprintf('Using image %d as start\n', starting_img)

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
slow_mo_seq = draw_path_overlay(slow_mo_seq, pred_trajectory, user_path, 'scale', 0.5);
write_video(slow_mo_seq, dataset);
h = implay(slow_mo_seq, 10);
set(h.Parent, 'Name', 'Slow motion')

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