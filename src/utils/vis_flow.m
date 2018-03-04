function vis_flow(flow, a, b)
flow = decimate_flow(flow, 10);

fprintf('Showing optical flow for image %d to %d\n', a, b)
figure
hold on;
set(gca,'Ydir','reverse')
quiver(flow(:, :, 1), flow(:, :, 2))
hold off
end

function new_flow = decimate_flow(flow, factor)
% DECIMATE_FLOW Reduce size of flow
[h, w, ~] = size(flow);
[Xq, Yq] = meshgrid(...
    linspace(1,w,w/factor),...
    linspace(1,h,h/factor));

new_flow = zeros(h/factor, w/factor, 2, 'single');
new_flow(:, :, 1) = interp2(flow(:, :, 1), Xq, Yq);
new_flow(:, :, 2) = interp2(flow(:, :, 2), Xq, Yq);
% After resizing the flow field, need to also amplify the magnitudes
% proportionally to the scaling factor
new_flow = new_flow / factor;
end