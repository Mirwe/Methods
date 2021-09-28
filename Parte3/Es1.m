clear;
clc;

months = (1:8)';
demand = [580, 700, 775, 650, 585, 760, 790, 815]';


%% Linear Regression
mdl = fitlm(months,demand,'linear');

test_demand = predict(mdl,months);

% figure
% plot(months,demand,'o',months,test_demand,'x')
% legend('Data','Predictions')
% errore=immse(test_demand,demand);
% MAPE= mean((abs(test_demand-demand))./demand);

next_months = (1:16)';
predicted_demand = predict(mdl,next_months);


%% Smoothing Esponenziale
alpha = 0.15;
prediction = zeros(1,16);
prediction(1) = demand(1);

for i=2:9
    prediction(i) = alpha * demand(i-1) + (1-alpha) * prediction(i-1);
end

