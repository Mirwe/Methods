clear;
clc;

%% Definizione problema
data = xlsread('TABELLE EROGATO.xlsx');
data = data(3:366,219:236);

%eliminate negative data
data(data<0)=NaN;

j=1;

for i=1: 3: 18
    erogato_PV{j} = data(:,i:i+2);
    j = j+1;
end

% Capienza autobotte in KL:
capienza_autob = 39;
costo_km = 0.5;

dist = [100 200 300 400 500 600];

% prezzo per unità
P = [1.5, 1.7, 1.6];

% Costo di mantenimento percentuale annuale
costo_perc = 0.03;
% storage cost per unità
cm = costo_perc*P;

%% Lotto economico

for i=1: length(erogato_PV)
  
    for j=1:3

        D(i,j) = mean(erogato_PV{i}(:,j), 'omitnan');
                    
        fo(i,j) = dist(i) * costo_km;

        Qstar(i,j) = sqrt(2*fo(i,j)*D(i,j)/cm(j));
        Tstar(i,j) = sqrt((2*fo(i,j))/(cm(j)*D(i,j)));
        Nstar(i,j) = sqrt((cm(j)*D(i,j))/(2*fo(i,j)));
    end
end


%% Wegnar-Within

T = 364;
for i=1: length(erogato_PV)
    
    for j=1:3
        %sum = cumsum(erogato_PV{i}(:,j), 'omitnan');
        %domanda(i,j) = sum(length(sum));
        domanda = erogato_PV{i}(:,j);
        domanda(isnan(domanda))=0;
        
        [cost, route] = WagnerWithin(fo(i,j),cm(j), domanda, T);
        cost_(i,j) = cost;
        route_{i}{j} = route;
    end
end

