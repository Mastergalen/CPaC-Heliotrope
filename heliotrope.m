
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
starting_img = 1;
imshow(seq(:, :, :, starting_img))
disp('Left-click on the image in order to draw the path')
disp('Double-click to finish drawing')

% FIXME: Reenable manual drawing for final version 
[x, y] = getpts;
% x = [832;1185.00000000000];
% y = [546.000000000000;561.000000000000];
user_path = [x, y];
n_pts = size(user_path, 1);
if n_pts < 2
    close all;
    error('You need to select at least 2 points')
end

fprintf("Selected %d points\n", n_pts);

G = to_graph(D);

start_point = user_path(1, :);
end_point = user_path(2, :);
sequence_order = best_path(G, flows_file, starting_img, start_point, end_point);

playback_path(seq, sequence_order)

implay(seq);


disp('Done')