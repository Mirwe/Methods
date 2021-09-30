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
 
%domanda del del pv i al tempo t 
d = [ 0 6000 0 0 3000 0 1000 0 3000
      0 1000 4000 0 0 0 0 11000 0
      1000 0 0 0 13000 0 0 0 0
      0 0 0 1000 0 0 0 0 0
      0 0 0 0 0 0 2000 0 0
      0 0 5000 0 0 5000 0 0 0];
T = 9;

% data = xlsread('TABELLE EROGATO.xlsx');
% data = data(3:366,219:236);
% 
% %eliminate negative data
% data(data<0)=NaN;
% data(isnan(data))=0;
% 
% d = [data(:,1),data(:,4),data(:,7),data(:,10),data(:,13),data(:,16)]';
% T=4;

prob = optimproblem;
   
%x(i,t) inventario del PV i al tempo t
x = optimvar('x', [num_PV T],'Type','continuous','LowerBound',0);

%q(i,t,k) quantità di prodotto servita al PV i, al tempo t, con lo
%scomparto k
q = optimvar('q',[num_PV T num_scomparti],'Type','continuous','LowerBound',0);

%y(i,t,k) 1 se PV i visitato al tempo t, con lo scomparto k
y = optimvar('y',[num_PV T num_scomparti],'Type','integer','LowerBound',0,'UpperBound',1);

v = optimvar('v',[num_PV T],'Type','integer','LowerBound',0,'UpperBound',1);

%delta(i,j,t) 1 se arco i,j usato al tempo t
delta = optimvar('delta',[num_PV num_PV T],'Type','integer','LowerBound',0,'UpperBound',1);

M = 999999;




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

%se ho consegnato con almeno un scomparto allora ho visitato
for t=1:T
    for i=1:num_PV
        pv_visited(i,t) = v(i,t) - y(i,t,1) == y(i,t,2);
    end
end

prob.Constraints.pv_visited = pv_visited;


costo_trasporto = 0;
costo_magazzino = 0;
cm = 40;

for t=1:T
    for i=1:num_PV
        
        costo_magazzino = costo_magazzino + x(i,t) * cm;
        
        costo_trasporto = costo_trasporto + dist_dep*v(i,t);
        
        
        for j=1:num_PV
            if(i~=j)
                costo_trasporto = costo_trasporto + OD(i,j) * delta(i,j,t);
            end
        end
    end
end


prob.Objective = costo_trasporto + costo_magazzino;


show(prob)

x0.x = zeros(num_PV,T);
x0.delta = zeros(num_PV, num_PV, T);
x0.v = zeros(num_PV, T);
x0.y = zeros(num_PV, T, num_scomparti);
x0.q = zeros(num_PV, T, num_scomparti);

sol = solve(prob, x0);







