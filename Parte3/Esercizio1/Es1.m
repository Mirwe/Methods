clear;
clc;

%% Inital data
% Demand for a given product abut the last 8 months
months = (1 : 8)';
demand = [580, 700, 775, 650, 585, 760, 790, 815]';

%% Linear Regression
% Fit linear regression model
mdl = fitlm(months, demand, 'linear');

%{
test_demand = predict(mdl, months);
figure
plot(months,demand,'o',months,test_demand,'x')
legend('Data','Predictions')
errore=immse(test_demand,demand);
MAPE= mean((abs(test_demand-demand))./demand);
%}



%Prediction for the next months
next_months = (9 : 16)';
LR_prediction = predict(mdl, next_months);


%% Exponential Smoothing
alpha = 0.15;
SE_prediction = zeros(1,16);

%The prediction for the first demand is equal to the demand itself
SE_prediction(1) = demand(1);

% Predictions computation
for i = 2 : 9
    SE_prediction(i) = alpha * demand(i-1) + (1-alpha) * SE_prediction(i-1);
end

