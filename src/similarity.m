function [ D ] = similarity( sequence )
%SIMILARITY Calculate similarity matrix between all frames
%   Only takes into account l2 norm

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

