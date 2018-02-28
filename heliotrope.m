
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

starting_img = 7;
imshow(seq(:, :, :, starting_img))
disp('Left-click on the image in order to draw the path')
disp('Double-click to finish drawing')

% FIXME: Reenable manual drawing for final version 
[x, y] = getline;
close;
user_path = [y, x];

% imshow(seq(:, :, :, starting_img))
% hold on
% scatter(user_path(:, 2), user_path(:, 1), 20, 'rx')

n_pts = size(user_path, 1);
if n_pts < 2
    close all;
    error('You need to select at least 2 points')
end

fprintf("Selected %d points\n", n_pts);

G = to_graph(D);

new_sequence = [starting_img];
for i = 2:n_pts
    start_point = user_path(i, :);
    end_point = user_path(i-1, :);
    sequence_order = best_path(G, flows_file, starting_img, start_point, end_point, seq);
    fprintf("Sequence: ");
    disp(sequence_order)
    new_sequence = [new_sequence sequence_order(2:end)];
    starting_img = sequence_order(end);
end


playback_path(seq, new_sequence)

% implay(seq);


disp('Done')