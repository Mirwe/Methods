%% This function implements the Wagner-Whitin algorithm
% Input parameters
% - fo: cost of the single order (fixed cost)
% - cm: storage cost per unit
% - d: demand for each day of the reference period
% - T: reference period
%
% Output parameters
% - cost: minimum (optimal) cost
% - route: optimal path
%
function [cost, route] = WagnerWhitin(fo, cm, d, T)
	costo = zeros(T + 1);
	for i = 1 : T
        for j = i + 1 : T + 1
            costo(i, j) = fo;
            for k = j - 1: - 1 : i
                for m = k : -1 : i + 1
                    costo(i, j) = costo(i, j) + cm * d(k);
                end
            end
        end
	end
	[cost, route] = dijkstra(costo, 1, T);
end