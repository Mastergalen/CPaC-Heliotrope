function [ min_path, min_pred_pts ] = best_path( G, flows_file, starting_node, start_point, end_point, seq, varargin )
%BEST_PATH Estimate best path give

defaultUseTrajectory = true;
alpha = 150; % Weight for trajectory cost

p = inputParser;
validBool = @(x) islogical(x);
addOptional(p, 'UseTrajectory', defaultUseTrajectory, validBool);
parse(p, varargin{:});

N = numnodes(G);

% Plot graph with similarity as weights
% figure
% plot(G, 'EdgeLabel',round(G.Edges.Weight));

TR = shortestpathtree(G, starting_node);
% figure
% plot(TR)
% title('Shortest path')

% TODO: Could improve performance by using DFS and caching previous flow
% value
% v = dfsearch(TR, starting_node);

min_cost = Inf;
min_path = [];
min_pred_pts = [NaN NaN];
for i = 1:N
    if i == starting_node
        continue
    end
    path = shortestpath(TR, starting_node, i);
    if isempty(path)
        error(sprintf('No path found from %d to %d', starting_node, i))
    end
    pred_pts = flow_predict(path, flows_file, start_point, seq);
    cost_distance = norm(end_point - pred_pts(end, :));

    if p.Results.UseTrajectory
        cost_trajectory = alpha * calc_trajectory_cost(flows_file, path, [start_point; pred_pts]);
    else
        cost_trajectory = 0;
    end
    
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

function C = calc_trajectory_cost(flows_file, path, pts)
% TRAJECTORY_COST Calculate trajectory similarity cost
% path | Vector of node indexes
% pts | (m by 2) matrix corresponding to path

prev_trajectory = read_trajectory(flows_file,...
    path(1), path(2), pts(1, :));

C = 0;
for i = 2:length(path)-1
    a = path(i);
    b = path(i + 1);
    
    current_trajectory = read_trajectory(flows_file, a, b, pts(i, :));
    C = C + norm(prev_trajectory - current_trajectory);
    
    prev_trajectory = current_trajectory;
end

% Normalise C to stop penalising longer paths
C = C / length(path);
end

function trajectory = read_trajectory(flows_file, a, b, point)
flow = get_flow(flows_file, a, b);

downscale_factor = 0.3;

point = point * downscale_factor;

trajectory = squeeze(flow(round(point(1)), round(point(2)), :));

% normalise
trajectory = trajectory / norm(trajectory);
end