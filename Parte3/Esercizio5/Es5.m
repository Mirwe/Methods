clear;
clc;

d = 2*60*cos(pi/6);

OD = [0   60  d   120 d   60 ;
     60  0   60  d   120 d  ;
     d   60  0   60  d   120;
     120 d   60  0   60  d ;
     d   120 d   60  0   60;
     60  d   120 d   60  0 ;];
 
dist_dep = 60;
cap_scomparto = [5000 6000];

num_PV = 6;
num_scomparti = 2;

data = xlsread('TABELLE EROGATO.xlsx');
data = data(3:366,219:236);

%eliminate negative data
data(data<0)=NaN;
data(isnan(data))=0;

d = [data(:,1),data(:,4),data(:,7),data(:,10),data(:,13),data(:,16)]';
T=14;

prob = optimproblem;
   
%x(i,t) inventario del PV i al tempo t
x = optimvar('x', [num_PV T],'Type','continuous','LowerBound',0);

%q(i,t,k) quantità di prodotto servita al PV i, al tempo t, con lo
%scomparto k
q = optimvar('q',[num_PV T num_scomparti],'Type','continuous','LowerBound',0);

%y(i,t,k) 1 se PV i visitato al tempo t, con lo scomparto k
y = optimvar('y',[num_PV T num_scomparti],'Type','integer','LowerBound',0,'UpperBound',1);

%delta(i,j,t) 1 se arco i,j usato al tempo t
delta = optimvar('delta',[num_PV num_PV T],'Type','integer','LowerBound',0,'UpperBound',1);

M = 10000000;

%Ipotiziamo che i PV abbiano già un 20% di prodotto in magazzino
for i=1:num_PV
    init(i) = x(i,1) == 0.2*sum(d(i,1:T));
end

prob.Constraints.init = init;


for t = 1:T-1
    max_quantity = 0;
    for i=1:num_PV
                
        quantity_delivered = 0;
               
        for k=1:num_scomparti
            quantity_delivered = quantity_delivered + q(i,t,k);                      
        end
        
        dinamica(i, t+1) = x(i, t+1) == x(i,t) - d(i,t)  + quantity_delivered;
        
        max_quantity = max_quantity + quantity_delivered;
        
    end
    
    max_delivery(t) = max_quantity <= 11000;
end

prob.Constraints.dynamics = dinamica;
prob.Constraints.max_delivery = max_delivery;

%al massimo 1 delivery per scomparti al giorno
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


for t=1:T
    somma_visited = 0;
    
    for i=1:num_PV
        
        for k=1:num_scomparti
            scomparto_usato(i,t,k) = q(i,t,k) - M * y(i,t,k) <= 0;
            
            %ogni scomparto deve essere usato interamente
            all_gas(i,t,k) = q(i,t,k) == y(i,t,k) * cap_scomparto(k);
        end
             
        for j=1:num_PV
            
            if(i~=j)
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
end

prob.Constraints.links = links;
prob.Constraints.scomparto_usato = scomparto_usato;
prob.Constraints.all_gas = all_gas;



costo_trasporto = 0;
costo_magazzino = 0;
cm = 0.03*1.5;
%price for transporting the fuel for each km
costo_km = 0.5;

for t=1:T
    for i=1:num_PV
        
        costo_magazzino = costo_magazzino + x(i,t) * cm;
        
        somma_scomparti_usati = 0;
        for k=1:num_scomparti
            somma_scomparti_usati = somma_scomparti_usati + y(i,t,k);
        end
        
        costo_trasporto = costo_trasporto + dist_dep * costo_km * somma_scomparti_usati;
        
        
        for j=1:num_PV
            if(i~=j)
                costo_trasporto = costo_trasporto + OD(i,j)* costo_km * delta(i,j,t);
            end
        end
    end
end


prob.Objective = costo_trasporto + costo_magazzino;


show(prob)

sol = solve(prob);







