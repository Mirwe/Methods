clear all;
clc;
%continuos time system;
m1 = 1;
m2 = 10;
teta = 30;
beta = 0.1;


Ac=[0 1 0 0 
    -teta/m1 -beta/m1 teta/m1 0
    0 0 0 1
    teta/m2 0 -teta/m2 -beta/m2];
Bc=[0 1/m1 0 0]'; 
C=[0 0 1 0];
D=zeros(1,1);

Q=[1];

Qf=Q;

%costo del controllo, aumentandolo il controllo sarà minore
R=1;

sample=0.1;
horizon=200;
t=0:sample:horizon;
N=length(t)-1;
sysc=ss(Ac,Bc,C,D);
sysd=c2d(sysc,sample);
Ad=sysd.a;
Bd=sysd.b;

%step 1
[P, K]=pk_riccati_output(Ad,Bd,C,Q,Qf,R,N);

%[Kinf2,Pinf2,e2]=dlqr(Ad,Bd,Q,R);
%[Kinf,Pinf,e]=lqr(sysd,Q,R);

% segnale da tracciare
%z = 100*ones(N+1,1)';
%z = [20*ones(N/4,1)' 40*ones(N/4,1)' 20*ones(N/4,1)' 40*ones(N/4,1)' 40];
%z = t;
z = 10* sin(1/5*t);

%segnale da tracciare su simulink
z_track2sml=[t' z'];

%step 2
[g, Lg]=Lg_xLQT(Ad,Bd,C,Q,Qf,R,N,P,z);

x0=[0 0 0 0]';
x(:,1)=x0;


% figure();
% initial(sysc, x0);
% hold on;
% initial(sysd, x0);

%STEP 3 and 4;
for i=1:N
    %optimal control
    u(:,i)=-K(:,:,i)*x(:,i)+Lg(:,:,i)*g(:,:,i+1);
    %optimal state for LQT to track z
    x(:,i+1)=Ad*x(:,i)+Bd*u(:,i);
    
    y(:,i+1)=C*x(:,i+1);
end

%figure();

subplot(3,1,1);
plot(t(1:N+1),x);
title('state');

subplot(3,1,2);
hold on
plot(t(1:N+1),y, 'b');
plot(t(1:N+1),z, 'r');
title('y');

subplot(3,1,3);
plot(t(1:N),u);
title('control');





