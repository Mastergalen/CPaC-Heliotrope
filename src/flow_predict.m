function [ destination ] = flow_predict( path, flows_file, start )
%FLOW_PREDICT Summary of this function goes here
%   Detailed explanation goes here

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
    
    dv = squeeze(flows_file.flows_a(round(destination(1)), round(destination(2)), :, k))';
    
    if a < b
        dv = -dv;
    end
    
    destination = destination + dv;
end

destination = round(destination / downscale_factor);

end

