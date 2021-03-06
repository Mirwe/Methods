clear;
clc;

%% Loading data
data = xlsread('TABELLE EROGATO.xlsx');
data = data(3 : 366, 219 : 236);

% removing negative values
data(data < 0) = NaN;
data(isnan(data))=0;

erogato_PV = {0, 0, 0};
j = 1;
for i = 1 : 3 : 18
    erogato_PV{j} = data(:, i : i + 2);
    j = j + 1;
end

% distance of each PV
dist = [686 690 691 693 699 719];

% price for transporting the fuel for each km
costo_km = 0.5;
sizeTruck = 39000;

% number of product for each PV
numP = 3;

% price for each product (fuel)
P = [1.5, 1.7, 1.6];

% reference period
period = 364;

% storage cost rate (for the reference period -> a year)
costo_perc = 0.03;

% storage cost for unit
cm = costo_perc * P;

%% Lot size problem
Qstar = zeros(length(erogato_PV), numP);
Tstar = zeros(length(erogato_PV), numP);
Nstar = zeros(length(erogato_PV), numP);

% Computation of relevant data for each product and PV 
for PV = 1 : length(erogato_PV)
    for p = 1 : numP

        D = sum(erogato_PV{PV}(:, p));
        transport_cost = costo_km * dist(PV);

        storageCost = zeros(1, period);
        orderCost = zeros(1, period);

        for q = 1 : D

            storageCost(q) = cm(p) * q / 2;

            nOfCamions = ceil(q / sizeTruck);
            
            orderCost(q) = (transport_cost * nOfCamions) * (D / q);
        end


        totCost = storageCost + orderCost; 
        [minCost, Q] = min(totCost);    
        
        % optimal quantity
        Qstar(PV,p) = Q;
        
        % optimal supply time
        Tstar(PV,p) = Q/D * period;
        
        %optimal number of orders
        Nstar(PV,p) = 1 / Tstar(PV,p);      
     end
end


%% Wagner-Whitin
cost_ = zeros(length(erogato_PV), numP);
route_ = {{}, {}, {}, {}, {}, {}};
quantity_ = {{}, {}, {}, {}, {}, {}};

for i = 1 : length(erogato_PV)
    for j = 1 : numP
        domanda = erogato_PV{i}(:, j);
        domanda(isnan(domanda)) = 0;
        
        fo = dist(i) * costo_km;
             
        [cost, route, quantity] = WagnerWhitin(fo, cm(j), domanda, period, sizeTruck);
        
        %Total cost
        cost_(i, j) = cost;
        
        %Days in which an order is made
        route_{i}{j} = route;
        
        %Quantity ordered for each day
        quantity_{i}{j} = quantity;
    end
end