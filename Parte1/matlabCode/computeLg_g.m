% Function to compute Lg and g for LQT
% A and B dynamics of the linear model
% C is the matrix related to the output
% Qf and Q state cost, R control cost
% setpoint: values to track
function  [g, Lg] = computeLg_g(Qf, Q, R, P, A, B, C, horizon, setpoint)
    W = C' * Q;
    E = B * R^(-1) * B';
    
    % g term computation
    g(:, :, horizon) = C' * Qf * setpoint(:, horizon);
    for i = horizon - 1 : -1 : 1
        g(:, :, i) = A' * (eye(size(A, 1)) - ...
            (pinv(P(:, :, i + 1)) + E)\E) * g(:, :, i + 1) + W * setpoint(:, i);
    end
    
    % Lg term computation
    for i = horizon - 1 : -1 : 1
        Lg(:, :, i) = (R + B' * P(:, :, i + 1) * B)\B';
    end
end
