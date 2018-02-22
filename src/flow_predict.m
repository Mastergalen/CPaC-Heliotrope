function [ destination ] = flow_predict( path, flows, start )
%FLOW_PREDICT Summary of this function goes here
%   Detailed explanation goes here

destination = start;

for i = 2:length(path)
    a = path(i-1);
    b = path(i);
    k = (a-1) * (a-2) / 2 + b;
    dv = flows(destination(1), destination(2), :, k);
    destination = destination + dv;
end

end

