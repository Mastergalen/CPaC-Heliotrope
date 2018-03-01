function [ flow ] = get_flow( flows_file, i, j )
%GET_FLOW Fetch optical flow field from frame i to j
% flows_file | Reference to flows.mat file
if i > j
    k = (i-1) * (i-2) / 2 + j;
else
    k = (j-1) * (j-2) / 2 + i;
end

flow = flows_file.flows_a(:, :, :, k);

if i < j
    flow = -flow;
end

end

