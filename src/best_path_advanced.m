function [ min_path, min_pred_pts ] = best_path_advanced( G, flows_file, starting_node, start_point, end_point, seq )
%BEST_PATH_ADVANCED Estimate best path

debug = false;
N = numnodes(G);

figure
plot(G, 'EdgeLabel',round(G.Edges.Weight));

TR = shortestpathtree(G, starting_node);
% figure
% plot(TR)
% title('Shortest path')

% TODO: Could improve performance by using DFS and caching previous flow
% value
% v = dfsearch(TR, starting_node);

alpha = 50; % Weight for trajectory cost

min_cost = Inf;
min_path = [];
min_pred_pts = [NaN NaN];
for i = 1:N
    if i == starting_node
        continue
    end
    path = shortestpath(TR, starting_node, i);
    pred_pts = flow_predict(path, flows_file, start_point, seq);
    cost_distance = norm(end_point - pred_pts(end, :));
    cost_trajectory = alpha * calc_trajectory_cost(flows_file, path);
    fprintf('Cost D: %f T: %f\n', cost_distance, cost_trajectory)
    cost = cost_distance + cost_trajectory;
    if cost < min_cost
        % fprintf("%f < %f | Updating min\n", distance, min_cost);
        min_cost = cost;
        min_path = path;
        min_pred_pts = pred_pts;
    end
end
end

function C = calc_trajectory_cost(flows_file, path)
% TRAJECTORY_COST Calculate trajectory similarity cost

prev_trajectory = calc_trajectory(flows_file, path(1), path(2));
C = 0;
for i = 2:length(path)-1
    a = path(i);
    b = path(i + 1);
    
    current_trajectory = calc_trajectory(flows_file, a, b);
    C = C + norm(prev_trajectory - current_trajectory);
end

% Normalise C to stop penalising longer paths
C = C / length(path);
end

function trajectory = calc_trajectory(flows_file, a, b)
flow = get_flow(flows_file, a, b);
trajectory = [mean2(flow(:, :, 1)) mean2(flow(:, :, 2))];
end