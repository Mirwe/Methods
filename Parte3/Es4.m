clear;
clc;

PV = [686, 690, 691, 693, 699, 719];

data = xlsread('TABELLE EROGATO.xlsx');

data = data(3:366,219:236);

%eliminate negative data
data(data<0)=NaN;

% Definire dati caratteristici - dimensione, periodo di consegna - ipotizzando 
% lotto economico con costo di magazzino pari al costo di immobilizzazione del capitale 
% (ad es. 3% del valore in magazzino) e costo di consegna effettuato tramite autobotte di 
% 39kl con costo 0.5€/km.

% Capienza autobotte in KL:
capienza_autob = 39;
costo_km = 0.5;
% Costo di mantenimento percentuale annuale:
costo_perc = 0.03;






