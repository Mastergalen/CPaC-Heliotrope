function playback_path( sequence, path, title, pred_pts, user_path )
%PLAYBACK_PATH Summary of this function goes here
%   Detailed explanation goes here
    [h, w, ~, ~] = size(sequence);

    new_sequence = zeros(h,w,3,length(path));
    
    disp('Playing back path:')
    disp(path)
    
    for i = 1:length(path)
        new_sequence(:, :, :, i) = sequence(:, :, :, path(i));
    end
    
    new_sequence = draw_path_overlay(new_sequence, pred_pts, user_path);
        
    h = implay(new_sequence);
    set(h.Parent, 'Name', title)
end

