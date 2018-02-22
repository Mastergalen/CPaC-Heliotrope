function playback_path( sequence, path )
%PLAYBACK_PATH Summary of this function goes here
%   Detailed explanation goes here
    [h, w, ~, ~] = size(sequence);

    new_sequence = zeros(h,w,3,length(path));
    
    for i = 1:length(path)
        new_sequence(:, :, :, i) = sequence(:, :, :, path(i));
    end
    
    disp('Playing back path:')
    disp(path)
        
    implay(new_sequence)
end

