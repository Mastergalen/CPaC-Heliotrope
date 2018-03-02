function [ D ] = better_similarity( sequence, flows_file )
%BETTER_SIMILARITY Calculate similarity matrix between all frames
% but also take into account trajectory
%   Detailed explanation goes here


[~, ~, ~, frames] = size(sequence);

D = zeros(frames, frames);

for i = 1:frames
    imgI = sequence(:, :, :, i);
    fprintf('Image i: %d\n', i);
    for j = i:frames
        if i == j
            continue
        end
        imgJ = sequence(:, :, :, j); 
        l2 = norm(imgI(:) - imgJ(:));
        D(i,j) = l2;
        D(j,i) = l2;
    end
end


end

function avg_flow