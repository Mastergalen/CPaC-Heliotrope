
addpath('src', 'src/utils')

disp('Loading sequence')
seq = load_sequence_color('sequence','gjbLookAtTarget_', 0, 71, 4, 'jpg');

if exist('cache/similarity.mat', 'file') == 2
    disp('Loading similarity from cache')
    load('cache/similarity.mat', 'D')
else
    disp('Calculating similarity')
    D = similarity(seq);
    save('similarity', 'D')
end

disp('Done')