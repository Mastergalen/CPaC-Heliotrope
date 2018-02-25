function min_path = best_path(G, flows_file, starting_node, start_point, end_point)
%BEST_PATH Estimate best path
N = numnodes(G);

TR = shortestpathtree(G, starting_node);
plot(TR)
% TODO: Could improve performance by using DFS and caching previous flow
% value
% v = dfsearch(TR, starting_node);

min_distance = Inf;
min_path = [];
for i = 1:N
    if i == starting_node
        continue
    end
    fprintf("Processing point %d\n", i);
    path = shortestpath(TR, starting_node, i);
    disp(path)
    pred_point = flow_predict(path, flows_file, start_point);
    disp(pred_point)
    distance = norm(end_point - pred_point);
    if distance < min_distance
        fprintf("%f < %f | Updating min\n", distance, min_distance);
        min_distance = distance;
        min_path = path;
    end
end
end