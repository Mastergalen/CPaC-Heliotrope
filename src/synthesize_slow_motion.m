function [ seq ] = synthesize_slow_motion( flows_file, seq, playback_path )
%SYNTHESIZE_SLOW_MOTION Synthesise slow motion through interpolation via
% optical flow
% flows_file | Reference to flows.mat file
% seq | Loaded image sequence
% playback_path | Array of video sequence indexes

steps = 10;

[h,w,~,~] = size(seq);

tform = eye(3);

disp('Synthesising slow motion')
    
for i = 2:length(playback_path)
    a = playback_path(i-1);
    b = playback_path(i);
    
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
    
    seq_len = steps + 1;
    new_seq = zeros(h, w, 3, seq_len);
    new_seq(:, :, :, 1) = seq(:, :, :, a);
    new_seq(:, :, :, end) = seq(:, :, :, b);
    for j = 2:seq_len-1
        imgA = imwarp(new_seq(:, :, :, j-1), big_flow);
        imgB = imwarp(new_seq(:, :, :, end), -big_flow * (seq_len - j));
        
        % Weighting between images depends on temporal distance from
        % original image 
        distanceA = j - 1;
        distanceB = seq_len - j;
        totalD = distanceA + distanceB;
        weightA = 1 - (distanceA / totalD);
        weightB = 1 - (distanceB / totalD);
        fused = (imgA * weightA) + (imgB * weightB);
        
        % vis_bi_interpolation(imgA, fused);
        
        new_seq(:, :, :, j) = fused;
    end    
    
    implay(new_seq)
end

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

