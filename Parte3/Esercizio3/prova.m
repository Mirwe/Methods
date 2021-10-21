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
period = 60;
Q = 2500;
costo_unit = 295;
domanda = normrnd(mu,sigma, [1,period]);

inventory = zeros(1,period);

inventory(1) = So;

tempo_consegna = 0;
already_ordered = false;

total_cost = 0;


for i=1:period
    
    if i == tempo_consegna      
        inventory(i) = inventory(i)+Q;
        already_ordered = false;
        total_cost = total_cost + Q*costo_unit;
    end
    
    if inventory(i) - domanda(i) > 0
        inventory(i+1) = inventory(i) - domanda(i);
    end
    
    if inventory(i) <= So && ~already_ordered
        tempo_consegna = i+tau;
        already_ordered = true;
    end    
    
end

plot(1:period, inventory(1:period))
h = yline(So, 'r');
a = yline(Ss, 'b');


