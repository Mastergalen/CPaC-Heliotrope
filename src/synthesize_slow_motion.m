function [ new_seq ] = synthesize_slow_motion( flows_file, seq, playback_path )
%SYNTHESIZE_SLOW_MOTION Synthesise slow motion through interpolation via
% optical flow
% flows_file | Reference to flows.mat file
% seq | Loaded image sequence
% playback_path | Array of video sequence indexes

% TODO: Calculate step size based on magnitude of optical flow
steps = 10;

[h,w,~,~] = size(seq);
checkpoints = length(playback_path);

fprintf('Synthesising slow motion: ')
disp(playback_path)

new_seq = zeros(h,w,3, checkpoints + ...
    (checkpoints - 1) * (steps - 1));
    
for i = 1:length(playback_path)-1
    a = playback_path(i);
    b = playback_path(i+1);
    
    flow = get_flow(flows_file, a, b) / steps;
    
    [h_s, w_s, ~] = size(flow);
    
    [Xq, Yq] = meshgrid(...
        linspace(1,w_s,w),...
        linspace(1,h_s,h));
    
    big_flow = zeros(h, w, 2, 'single');
    big_flow(:, :, 1) = interp2(flow(:, :, 1), Xq, Yq);
    big_flow(:, :, 2) = interp2(flow(:, :, 2), Xq, Yq);
    % After resizing the flow field, need to also amplify the magnitudes
    % proportionally to the scaling factor
    big_flow = big_flow * (h / h_s);
    
    % Need to reverse big_flow for displacement map
    big_flow = -big_flow;
    
    % vis_flow(big_flow, a, b)
    
    start_idx = ((i-1) * steps) + 1;
    new_seq(:, :, :, start_idx) = seq(:, :, :, a);
    for j = 1:steps-1
        imgA = imwarp(seq(:, :, :, a), big_flow * j);
        imgB = imwarp(seq(:, :, :, b), -big_flow * (steps - j));
        
        % Weighting between images depends on temporal distance from
        % original image 
        distanceA = j;
        distanceB = steps - j;
        totalD = distanceA + distanceB;
        weightA = 1 - (distanceA / totalD);
        weightB = 1 - (distanceB / totalD);
        fused = (imgA * weightA) + (imgB * weightB);
        
        % vis_bi_interpolation(imgA, fused);
        
        new_seq(:, :, :, start_idx + j) = fused;
    end    
end

new_seq(:, :, :, end) = seq(:, :, :, playback_path(end));
end

function vis_bi_interpolation(original, fused)
figure
subplot(1,2,1)
imshow(original)
title('Original')
subplot(1,2,2)
imshow(fused)
title('Fused')
end

function vis_flow(flow, from, to)
figure
hold on
set(gca,'Ydir','reverse')
title(sprintf('From %d to %d', from, to))
quiver(flow(:, :, 1), flow(:, :, 2))
hold off
end

