function [ destination ] = flow_predict( path, flows_file, start )
%FLOW_PREDICT Summary of this function goes here
%   Detailed explanation goes here

debug = false;
downscale_factor = 0.3;

destination = round(start * downscale_factor);

for i = 2:length(path)
    a = path(i-1);
    b = path(i);
    if a > b
        k = (a-1) * (a-2) / 2 + b;
    else
        k = (b-1) * (b-2) / 2 + a;
    end
    
    flow = flows_file.flows_a(:, :, :, k);
    
    if debug
        figure
        hold on;
        quiver(flow(:, :, 1), flow(:, :, 2))
        % opflow = opticalFlow(flow(:, :, 1), flow(:, :, 2));
        % plot(opflow, 'DecimationFactor', [10, 10])
        scatter(0, 100, 50, 'r.')
    end
    
    dv = squeeze(flow(round(destination(1)), round(destination(2)), :))';
    
    if a < b
        dv = -dv;
    end
    
    % dv = (vx,vy)
    % destination = (y,x)
    % Need to reverse order of dv 
    destination = destination + [dv(2), dv(1)];
end

destination = round(destination / downscale_factor);

end

