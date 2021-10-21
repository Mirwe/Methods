clear;
clc;

%% Initial data
% Reorder time -> 10 days
tau = 10; 

% The demand is normal distributed
mu = 150; %units/day
sigma = 5; %units/day

%service level of 95%
zeta = 1.65;


%% Computation
% Safety stock
Ss = zeta * sigma * sqrt(tau);

% Reorder point
So = mu * tau + Ss;


%%
period = 100;
Q = 300;
costo_unit = 295;
domanda = normrnd(mu,sigma, [1,period]);

numDays = So/mu;



inventory = zeros(1,period);

inventory(1) = So;

tempo_consegna = zeros(1,period);
already_ordered = false;

total_cost = 0;

Qordered = 0;

for i=1:period
    
    %if i == tempo_consegna 
    if ismember(i, tempo_consegna) == 1
        inventory(i) = inventory(i)+Q;
        already_ordered = false;
        total_cost = total_cost + Q*costo_unit;
    end
    

    inventory(i+1) = inventory(i) - domanda(i);
    
    
    if inventory(i) <= So% && ~already_ordered
        tempo_consegna(i) = i+tau;
        %already_ordered = true;
        %Qordered = mu*(tau+tau) + Ss - inventory(i);
    end    
    
end

plot(1:period, inventory(1:period))
h = yline(So, 'r');


