clear;
clc;

%% Initial Data
% 5 products: A B C D E
scorta_iniziale = [100, 60, 800, 520, 1500];
quantita_acquistata = [500, 50, 1200, 13400, 400];
scorta_finale = [20, 80, 800, 1450, 1100];

%% Inventory KPI

% Average stock 
C = (scorta_iniziale + scorta_finale)/2;

% Total output flow
Q = scorta_iniziale + quantita_acquistata - scorta_finale;

% Rotation Index
IR = Q./C;
