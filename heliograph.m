
addpath('src', 'src/utils')

disp('Loading sequence')
seq = load_sequence_color('sequence','gjbLookAtTarget_', 0, 71, 4, 'jpg');

if exist('data/similarity.mat', 'file') == 2
    disp('Loading similarity from cache')
    load('data/similarity.mat', 'D')
else
    disp('Calculating similarity')
    D = similarity(seq);
    save('data/similarity', 'D')
end

load('data/flows.mat', 'flows_a')

G = to_graph(D);

[dist, path, pred] = graphshortestpath(G, 28, 22);

playback_path(seq, path)

implay(seq);


disp('Done')