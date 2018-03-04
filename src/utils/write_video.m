function write_video( sequence, name )
%WRITE_VIDEO Write video as mp4

disp('Writing video');
[~, ~, ~, frames] = size(sequence);

outputVideo = VideoWriter(fullfile('',sprintf('%s.mp4', name)), ...
    'MPEG-4');
outputVideo.FrameRate = 10;
open(outputVideo)

for t = 1:frames
   img = sequence(:, :, :, t);
   img = im2uint8(img);
   writeVideo(outputVideo, img);
end

end


