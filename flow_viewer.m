% Script to inspect flows file

addpath('src/utils');

% data = load('data/trump_flows.mat', 'flows');
flows_file = matfile('data/trump_flows.mat');

% flows_a = data.flows;

% save('data/trump_flows', 'flows_a')

a = 4;
b = 5;

f = get_flow(flows_file, a, b);

vis_flow(f, a, b);