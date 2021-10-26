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
% - quantity: optimal quantity to be ordered for each order
%
function [cost, route, quantity] = WagnerWhitin(fo, cm, d, T, cap_truck)
	costo = zeros(T + 1);
	for i = 1 : T
        for j = i + 1 : T + 1
            costo(i, j) = fo * ceil(sum(d(i : (j - 1), 1)) / cap_truck);
            for k = j - 1: - 1 : i
                for m = k : -1 : i + 1
                    costo(i, j) = costo(i, j) + cm * d(k);
                end
            end
        end
	end
	[cost, route] = dijkstra(costo, 1, T);
    
    quantity = zeros(1, length(route));

    to = T;
    from = route(1);
    quantity(1) = sum(d(from : to));
    
    k = 2;
    for i = 1 : length(route) - 1
        
        from = route(i + 1); 
        to = route(i) - 1; 
        
        quantity(k) = sum(d(from : to));
        k = k + 1;
    end
    
    
    
end