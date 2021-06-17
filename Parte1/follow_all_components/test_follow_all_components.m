clear;
clc;

%% Definition of the continuos time system;
% masses of the carts
m1 = 30;
m2 = 20;

%elastic constant
teta = 50;

%friction coefficient
beta = 0.8;

% matrices of the system
Ac = [0 1 0 0 
     -teta/m1 -beta/m1 teta/m1 0
      0 0 0 1
      teta/m2 0 -teta/m2 -beta/m2];
  
Bc = [0 1/m1 0 0]'; 
C = [0, 0, 1, 0];
D = zeros(1,1);

%initial state
x0 = [0 0 0 0]';
x(:, 1) = x0;

sysc = ss(Ac, Bc, C, D);

%% Discretization of the system defined above
sampleTime = 0.1;
horizon = 200;
t = 0 : sampleTime : horizon;
N = length(t);

sysd = c2d(sysc, sampleTime);

Ad = sysd.a;
Bd = sysd.b;


%% Control computation
% signal to track
z = [t
    ones(1,N)
    t
    ones(1,N)];

% state cost
Q = [100 0 0 0
     0 1 0 0
     0 0 100 0
     0 0 0 1];
Qf = Q;

% control cost, by augmenting it the system will be less controlled
R = 1;

[L, Lg, g] = compute_Riccati_Lg_g(Q, R, Qf, Ad, Bd, z, N);


u = zeros(1, N-1);
x = zeros(4, N);

for i = 1 : N-1
    % Calcolo del controllo ottimo
    u(:,i) = L(:,:,i) * x(:,i) + Lg(:,:,i) * g(:,i+1);

    % Evoluzione del sistema affetto dal controllo
    x(:,i+1) = Ad * x(:, i) + Bd * u(i);
    
end

for i = 1 : N
    y(:,i) = C * x(:, i);
end



subplot(4,1,1)
plot(t, z(1,:), 'g');
hold on
plot(t, x(1,:), 'r');
hold off;

subplot(4,1,2)
plot(t, z(2,:), 'g');
hold on
plot(t, x(2,:), 'r');
hold off;

subplot(4,1,3)
plot(t, z(3,:), 'g');
hold on
plot(t, x(3,:), 'r');
hold off;

subplot(4,1,4)
plot(t, z(4,:), 'g');
hold on
plot(t, x(4,:), 'r');
hold off;

