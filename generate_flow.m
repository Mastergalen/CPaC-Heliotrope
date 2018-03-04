% Generate flows.mat for my own image sequence
addpath('lib/flow');
addpath('src/utils');

resize_factor = 0.3;

disp('Loading sequence')
seq = load_sequence_color('data/trump','trump_', 0, 46, 4, 'png');
[h, w, ~, n] = size(seq);
small_seq = zeros(h * resize_factor, w * resize_factor, 3, n);

disp('Resizing')
for t = 1:n
    small_seq(:, :, :, t) = imresize(seq(:, : ,:, t), resize_factor, 'bicubic');
end

clear seq;

% set optical flow parameters (see Coarse2FineTwoFrames.m for the definition of the parameters)
alpha = 0.012;
ratio = 0.75;
minWidth = 20;
nOuterFPIterations = 7;
nInnerFPIterations = 1;
nSORIterations = 30;

para = [alpha,ratio,minWidth,nOuterFPIterations,nInnerFPIterations,nSORIterations];

% number of flows to calculate (without diagonal)
flow_count = n * (n - 1) / 2;

flows_a = zeros(h * resize_factor, w * resize_factor, 2, flow_count);

fprintf('Calculating %d optical flows\n', flow_count)
flow_i = 1;
for i = 2:n
    fprintf('Column %d\n', i)
    im1 = small_seq(:, :, :, i);
    for j = 1:i-1
        fprintf('Row %d Flow_i %d\n', j, flow_i)
        tic;
        im2 = small_seq(:, :, :, j);
        [vx,vy,warpI2] = Coarse2FineTwoFrames(im1, im2, para);
        flows_a(:, :, 1, flow_i) = vx;
        flows_a(:, :, 2, flow_i) = vy;
        flow_i = flow_i + 1;
        toc;
    end
end

disp('Finished')
save('data/trump_flows', 'flows_a', '-v7.3');