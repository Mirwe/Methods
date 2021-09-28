clear;
clc;

mu = 150;
sigma = 5;
tau = 10;
zeta = 1.65; %% 95% safety 


%% Reorder point
d = mu;
Ss = zeta*sigma*sqrt(tau);
S0 = d*tau + Ss;
