function [ new_seq ] = synthesize_slow_motion( flows_file, seq, playback_path )
%SYNTHESIZE_SLOW_MOTION Synthesise slow motion through interpolation via
% optical flow
% flows_file | Reference to flows.mat file
% seq | Loaded image sequence
% playback_path | Array of video sequence indexes

% TODO: Calculate step size based on magnitude of optical flow
steps = 10;
scale_factor = 0.4;

[h,w,~,~] = size(seq);
h_out = scale_factor * h;
w_out = scale_factor * w;
checkpoints = length(playback_path);

fprintf('Synthesising slow motion: ')
disp(playback_path)

new_seq = zeros(h_out,w_out,3, checkpoints + ...
    (checkpoints - 1) * (steps - 1));
    
for i = 1:length(playback_path)-1
    a = playback_path(i);
    b = playback_path(i+1);
    
    flow = get_flow(flows_file, a, b) / steps;
    
    [h_flow, w_flow, ~] = size(flow);
    
    [Xq, Yq] = meshgrid(...
        linspace(1,w_flow,w_out),...
        linspace(1,h_flow,h_out));
    
    flow_resized = zeros(h_out, w_out, 2, 'single');
    flow_resized(:, :, 1) = interp2(flow(:, :, 1), Xq, Yq);
    flow_resized(:, :, 2) = interp2(flow(:, :, 2), Xq, Yq);
    % After resizing the flow field, need to also amplify the magnitudes
    % proportionally to the scaling factor
    flow_resized = flow_resized * (h_out / h_flow);
    
    % Need to reverse big_flow for displacement map
    flow_resized = -flow_resized;
    
    % vis_flow(big_flow, a, b)
    
    start_idx = ((i-1) * steps) + 1;
    new_seq(:, :, :, start_idx) = imresize(seq(:, :, :, a), scale_factor);
    for j = 1:steps-1
        imgA = imwarp(...
            imresize(seq(:, :, :, a), scale_factor),...
            flow_resized * j);
        imgB = imwarp(...
            imresize(seq(:, :, :, b), scale_factor),...
            -flow_resized * (steps - j));
        
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

new_seq(:, :, :, end) = imresize(...
    seq(:, :, :, playback_path(end)), scale_factor);
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

