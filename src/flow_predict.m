function [ predicted ] = flow_predict( path, flows_file, start, seq )
%FLOW_PREDICT Summary of this function goes here
%   Detailed explanation goes here

debug_flow = false;
downscale_factor = 0.3;

predicted = round(start * downscale_factor);

for i = 2:length(path)
    a = path(i-1);
    b = path(i);
    if a > b
        k = (a-1) * (a-2) / 2 + b;
    else
        k = (b-1) * (b-2) / 2 + a;
    end
    
    flow = flows_file.flows_a(:, :, :, k);
    
    if a < b
        flow = -flow;
    end
    
    dv = squeeze(flow(round(predicted(1)), round(predicted(2)), :))';
    
    old_destination = predicted;
    
    % dv has format (vx,vy)
    % destination has format (y,x)
    % Need to reverse order of dv 
    predicted = predicted + [dv(2), dv(1)];
    
    if debug_flow
        fprintf('Showing optical flow for image %d to %d\n', a, b)
        figure
        hold on;
        set(gca,'Ydir','reverse')
        quiver(flow(:, :, 1), flow(:, :, 2))
        % opflow = opticalFlow(flow(:, :, 1), flow(:, :, 2));
        % plot(opflow, 'DecimationFactor', [10, 10])
        scatter(old_destination(2), old_destination(1), 50, 'r.')        
        scatter(predicted(2), predicted(1), 50, 'g.')
        hold off
        
        figure
        imshow(seq(:,:,:,a))
        hold on
        scatter(old_destination(2) / downscale_factor, old_destination(1) / downscale_factor, 50, 'r.')        
        scatter(predicted(2) / downscale_factor, predicted(1) / downscale_factor, 50, 'g.')
        hold off
        
        error('Debugging')
    end
    
end

predicted = round(predicted / downscale_factor);

end

