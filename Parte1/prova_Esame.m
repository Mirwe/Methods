clear;
clc;

%% Definition of the continuos time system;
% masses of the carts
m1 = 1;
m2 = 10;

%elastic constant
teta = 30;

%friction coefficient
beta = 0.1;

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

%% check controllability
co = ctrb(sysc);
controllability = rank(co);

%% discretization of the system defined above
sampleTime = 0.1;
horizon = 200;
t = 0 : sampleTime : horizon;
N = length(t);

sysd = c2d(sysc, sampleTime);

Ad = sysd.a;
Bd = sysd.b;

%% Control computation
% state cost
Q = 1;
Qf = Q;

% control cost, by augmenting it the system will be less controlled
R = 1;

% STEP 1
[L, P] = riccati_tracking(Qf, Q, R, Ad, Bd, C, N);

% signal to track
%z = 100 * ones(N, 1)';
%z = t;
%z = square(1/20 * t);
z = 10 * sin(1/5 * t);

%segnale da tracciare su simulink
z_track2sml = [t' z'];

% STEP 2
[g, Lg] = computeLg_g(Qf, Q, R, P, Ad, Bd, C, N, z);

% preallocation of the control variable just to increase the speed script
u = zeros(1, N - 1);

% preallocation of the control variable just to increase the speed script
y = zeros(1, N);

% STEP 3 and 4;
for i = 1 : N - 1
    %optimal control
    u(:, i)= -L(:, i)' * x(:, i) + Lg(:, :, i) * g(:, :, i + 1);
    
    %optimal state for LQT to track z
    x(:, i + 1) = Ad * x(:, i) + Bd * u(:, i);
end

for i = 1 : N
    %output
    y(:, i)= C * x(:, i);
end

%plotting
% subplot(3, 1, 1);
% plot(t, x(3, :));
% title('states');

subplot(2, 1, 1);
plot(t, y(1, :), 'b');
hold on;
plot(t, z, 'r');
title('output');
hold off;

subplot(2, 1, 2);
plot(t(1 : end - 1), u);
title('control');