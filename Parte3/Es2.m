clear;
clc;

scorta_iniziale = [100, 60, 800, 520, 1500];
quantita_acquistata = [500, 50, 1200, 13400, 400];
scorta_finale = [20, 80, 800, 1450, 1100];


S = scorta_iniziale + quantita_acquistata; % + scorta_finale?;
C = S/12;
Q = S - scorta_finale;

IR = Q./C;
