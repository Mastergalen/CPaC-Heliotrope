function min_path = best_path(G, flows_file, starting_node, start_point, end_point, seq)
%BEST_PATH Estimate best path
debug = false;
N = numnodes(G);

TR = shortestpathtree(G, starting_node);
plot(TR)
% TODO: Could improve performance by using DFS and caching previous flow
% value
% v = dfsearch(TR, starting_node);

min_distance = Inf;
min_path = [];
min_pred_point = zeros(size(end_point));
for i = 1:N
    if i == starting_node
        continue
    end
    path = shortestpath(TR, starting_node, i);
    pred_point = flow_predict(path, flows_file, start_point, seq);
    distance = norm(end_point - pred_point);
    if distance < min_distance
        fprintf("%f < %f | Updating min\n", distance, min_distance);
        min_distance = distance;
        min_path = path;
        min_pred_point = pred_point;
    end
end

if debug
    figure
    subplot(1,2,1)
    imshow(seq(:, :, :, min_path(1)))
    title(sprintf('Starting Image %d', min_path(1)))
    hold on
    scatter(start_point(2), start_point(1), 50, 'g.')
    scatter(end_point(2), end_point(1), 50, 'bx')
    scatter(min_pred_point(2), min_pred_point(1), 50, 'r.')
    legend('Start', 'Target', 'Predicted')
    hold off

    subplot(1,2,2)
    imshow(seq(:, :, :, min_path(end)))
    title(sprintf('End Image %d', min_path(end)))
    hold on
    scatter(start_point(2), start_point(1), 50, 'g.')
    scatter(end_point(2), end_point(1), 50, 'bx')
    scatter(min_pred_point(2), min_pred_point(1), 50, 'r.')
    hold off
end
end