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
