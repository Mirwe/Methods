clear;
clc;

%% Initial Data
% 5 products: A B C D E
scorta_iniziale = [100, 60, 800, 520, 1500];
quantita_acquistata = [500, 50, 1200, 13400, 400];
scorta_finale = [20, 80, 800, 1450, 1100];

%% Inventory control KPIs
% Total inventory level
S = scorta_iniziale + quantita_acquistata; % + scorta_finale?;

% Average consistency 
C = S/12;

% Total output flow
Q = S - scorta_finale;

%Rotation Index
IR = Q./C;
