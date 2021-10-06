clear;
clc;

%% Loading data
data = xlsread('TABELLE EROGATO.xlsx');
data = data(3 : 366, 219 : 236);

% removing negative values
data(data < 0) = NaN;

erogato_PV = {0, 0, 0};
j = 1;
for i = 1 : 3 : 18
    erogato_PV{j} = data(:, i : i + 2);
    j = j + 1;
end

%% Info PV and products
% distance of each PV
dist = [100 200 300 400 500 600];

%price for transporting the fuel for each km
costo_km = 0.5;
sizeTruck = 39000;

% number of product for each PV
numP = 3;
P = [1.5, 1.7, 1.6]; % price for each product (fuel)

%reference period
period = 364; %a quanto pare manca il 1° Gennaio e quindi sono 364 giorni e non 365 

% storage cost rate (for the reference period -> a year)
costo_perc = 0.03;

% storage cost for unit
cm = costo_perc * P;

fo = zeros(length(erogato_PV), numP);
Dday = zeros(length(erogato_PV), numP);
Dtot = zeros(length(erogato_PV), numP);
Qstar = zeros(length(erogato_PV), numP);
Tstar = zeros(length(erogato_PV), numP);
Nstar = zeros(length(erogato_PV), numP);

%% Lotto economico
for i = 1 : length(erogato_PV)
    for j = 1 : numP
        Dtot(i, j) = sum(erogato_PV{i}(:, j), 'omitnan');
        
        % cost of a single order
        fo(i, j) = dist(i) * costo_km;
    
        % optimal quantity of fuel to deliver to minimize costs
        Qstar(i, j) = sqrt(2 * fo(i, j) * Dtot(i, j) / cm(j));
        
        % optimal supply time
        Tstar(i, j) = sqrt((2 * fo(i, j)) / (cm(j) * Dtot(i, j)));
        
        % optimal number of orders for each fuel
        Nstar(i, j) = sqrt((cm(j) * Dtot(i, j)) / (2 * fo(i, j)));
    end
end

viaggi_necessari = ceil(Qstar./sizeTruck);%serve/si fa cosi? 

% Ho messo il costo totale per completezza (potremmo lasciarlo o toglierlo)
% Poi voglio farti un ragionamento basato sulla formula per calcolare la
% Qstar
storageCost = zeros(length(erogato_PV), numP);
orderingCost = zeros(length(erogato_PV), numP);
totCost = zeros(length(erogato_PV), numP);
for i = 1 : length(erogato_PV)
    for j = 1 : numP
        storageCost(i, j) = cm(j) * (Qstar(i, j) / 2);
        orderingCost(i, j) = fo(i, j) * ceil(Qstar(i, j) / sizeTruck) * (Dtot(i, j) / Qstar(i, j));

        % total cost of managing the inventory in the reference period
        totCost(i, j) = storageCost(i, j) + orderingCost(i, j);
    end
end

%% Wagner-Whitin
cost_ = zeros(length(erogato_PV), numP);
route_ = {{}, {}, {}, {}, {}, {}};

for i = 1 : length(erogato_PV)
    for j = 1 : numP
        domanda = erogato_PV{i}(:, j);
        domanda(isnan(domanda)) = 0;
        
        [cost, route] = WagnerWhitin(fo(i, j), cm(j), domanda, period);
        cost_(i, j) = cost;
        route_{i}{j} = route;
    end
end

