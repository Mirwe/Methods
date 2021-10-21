clear;
clc;

%% Dati
dist_dep = 60;
cap_scomparto = [5000 6000];
num_scomparti = length(cap_scomparto);
num_PV = 6;

d = 2*60*cos(pi/6);

% matrice delle distanze tra PV
OD = [0   60  d   120 d   60 ;
     60  0   60  d   120 d  ;
     d   60  0   60  d   120;
     120 d   60  0   60  d ;
     d   120 d   60  0   60;
     60  d   120 d   60  0 ;];
 
data = xlsread('TABELLE EROGATO.xlsx');
data = data(3:366,219:236);

%eliminazione dati non validi
data(data<0)=NaN;
data(isnan(data))=0;

index_day = 1;

%Solo prodotto B95
d = [data(index_day:364,1),data(index_day:364,4),data(index_day:364,7), ...
    data(index_day:364,10),data(index_day:364,13),data(index_day:364,16)]';

%Periodo
T = 10;


%% Definizione problema di ottimizzazione
prob = optimproblem;
   
%x(i,t) inventario del PV i al tempo t
x = optimvar('x', [num_PV T],'Type','continuous','LowerBound',0);

%q(i,t,k) quantità di prodotto servita al PV i, al tempo t, con lo
%scomparto k
q = optimvar('q',[num_PV T num_scomparti],'Type','continuous','LowerBound',0);

%u(t) = 1 se il camion esce al tempo t
u = optimvar('u',T,'Type','integer','LowerBound',0, 'UpperBound',1);

%y(i,t,k) = 1 se PV i visitato al tempo t, con lo scomparto k
y = optimvar('y',[num_PV T num_scomparti],'Type','integer','LowerBound',0,'UpperBound',1);

%delta(i,j,t) = 1 se arco dal PV i al PV j usato al tempo t
delta = optimvar('delta',[num_PV num_PV T],'Type','integer','LowerBound',0,'UpperBound',1);

M = 10000000;

%% Inizializzazione vincoli
init = optimconstr(num_PV);
dinamica = optimconstr(num_PV, T);
max_delivery = optimconstr(T);
inventory = optimconstr(num_PV, T);
max_deliveries = optimconstr(num_PV, num_scomparti);
scomparto_usato = optimconstr(num_PV, T, num_scomparti);
all_gas = optimconstr(num_PV, T, num_scomparti);
camion_esce = optimconstr(T);
links = optimconstr(num_PV, num_PV, T);

%% Ipotiziamo che i PV abbiano già un 30% di prodotto in magazzino
for i=1:num_PV
    init(i) = x(i,1) == 0.3*sum(d(i,1:T));
end

prob.Constraints.init = init;

%% Vincoli per la dinamica dell'inventario 
for t = 1:T-1
    max_quantity = 0;
    for i=1:num_PV
                
        quantity_delivered = 0;
               
        for k=1:num_scomparti
            quantity_delivered = quantity_delivered + q(i,t,k);                      
        end
        
        dinamica(i, t+1) = x(i, t+1) == x(i,t) - d(i,t)  + quantity_delivered;
        
    end
end

prob.Constraints.dynamics = dinamica;

%% Vincoli per quantità massima consegnata totale

for t = 1:T
    max_quantity = 0;
    for i=1:num_PV
                
        quantity_delivered = 0;
               
        for k=1:num_scomparti
            quantity_delivered = quantity_delivered + q(i,t,k);                      
        end
        
        max_quantity = max_quantity + quantity_delivered;
        
    end
    
    max_delivery(t) = max_quantity <= 11000;
end
prob.Constraints.max_delivery = max_delivery;

%% Vincoli per numero massimo di consegne per scomparto e vincoli per soddisfare domanda giornaliera

for t = 1:T  
    for i=1:num_PV
        inventory(i,t) = x(i,t) >= d(i,t);
    end
    
    for k = 1:num_scomparti
        number_deliveries = 0;
        for i=1:num_PV
            number_deliveries = number_deliveries + y(i,t,k);
        end
        max_deliveries(t, k) = number_deliveries <= 1;
    end
  
end

prob.Constraints.inventory = inventory;
prob.Constraints.max_deliveries = max_deliveries;

%% Vincoli relativi agli scomparti

for t=1:T
    somma_quantita = 0;
    for i=1:num_PV
        
        for k=1:num_scomparti
            % se q(i,t,k)>0 allora il PV i è visitato al tempo t con lo
            % scomparto k
            scomparto_usato(i,t,k) = q(i,t,k) - M * y(i,t,k) <= 0;
              
            somma_quantita = somma_quantita + q(i,t,k);
                   
            %ogni scomparto deve essere usato interamente
            all_gas(i,t,k) = q(i,t,k) == y(i,t,k) * cap_scomparto(k);
        end
             
    end
    
    camion_esce(t) = somma_quantita - M * u(t) <= 0;

end

prob.Constraints.scomparto_usato = scomparto_usato;
prob.Constraints.camion_esce = camion_esce;
prob.Constraints.all_gas = all_gas;

%% Vincoli per definire spostamenti tra due PV

for t=1:T
    somma_visited = 0;
    
    for i=1:num_PV
        somma_visited = 0;
        for j=i+1:num_PV

            num_visited_i = 0;
            num_visited_j = 0;

            for k=1:num_scomparti

                num_visited_i = num_visited_i + y(i,t,k);
                num_visited_j = num_visited_j + y(j,t,k);
            end

            links(i,j,t) = num_visited_i + num_visited_j - 1 <= delta(i,j,t);
            
        end
    end
end
prob.Constraints.links = links;


%% Definizione della funzione di costo

costo_trasporto = 0;
costo_magazzino = 0;

% costo di magazzinamento
cm = 0.03*1.5;

% costo di trasporto al km
costo_km = 0.5;



for t=1:T
    costo_trasporto = costo_trasporto + dist_dep * 2 * costo_km * u(t);
    
    for i=1:num_PV
        
        costo_magazzino = costo_magazzino + x(i,t) * cm;
        
        somma_scomparti_usati = 0;
        for k=1:num_scomparti
            somma_scomparti_usati = somma_scomparti_usati + y(i,t,k);
        end
                
        for j=1:num_PV
            if(i~=j)
                costo_trasporto = costo_trasporto + OD(i,j)* costo_km * delta(i,j,t);
            end
        end
    end
end


prob.Objective = costo_trasporto + costo_magazzino;


%% Soluzione

show(prob)

sol = solve(prob);







