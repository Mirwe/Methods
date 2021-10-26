clear;
clc;

%% Initial data
% Demand for a given product about the last 8 months
months = (1 : 8)';
demand = [580, 700, 775, 650, 585, 760, 790, 815]';

%% Linear Regression
% Fit linear regression model
mdl = fitlm(months, demand, 'linear');

test_demand = predict(mdl, months);
figure
plot(months, demand, 'o', months, test_demand, 'x')
legend('Data', 'Linear Regression')

%mean squared error
mse_LR = immse(test_demand, demand);

%Prediction for the next months
next_months = (1 : 16)';
LR_prediction = predict(mdl, next_months);


%% Exponential Smoothing
%exponential avarage constant
alpha = 0.15;
SE_prediction = zeros(1, 9);

%The prediction for the first demand is equal to the demand itself
SE_prediction(1) = demand(1);

% Predictions computation
for t = 1 : 8
    SE_prediction(t + 1) = alpha * demand(t) + (1 - alpha) * SE_prediction(t);
end

%mean squared error
mse_SE = immse(SE_prediction(1 : 8)', demand);

figure
plot(months, demand, 'o', months, SE_prediction(1 : 8), 'x')
legend('Data', 'Exponential smoothing')

