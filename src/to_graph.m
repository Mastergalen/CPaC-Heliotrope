function [ G ] = to_graph( distance )
%TO_GRAPH Convert distance matrix to graph
THRESHOLD = 210;

deletion_mask = distance > THRESHOLD;
distance(deletion_mask) = 0;

G = graph(distance);

% figure
% plot(G);
end