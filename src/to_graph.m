function [ G ] = to_graph( distance )
%GRAPH Summary of this function goes here
%   Detailed explanation goes here
THRESHOLD = 150;

diff = distance < THRESHOLD;
G = and(diff, distance > 0.0);
G = sparse(G);
visualise_graph = graph(G);

plot(visualise_graph);
end