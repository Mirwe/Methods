% Function to compute P riccati matrix and L for LQT
% A and B dynamics of the linear model
% C is the matrix related to the output
% Qf and Q state cost, R control cost
function [L, P] = riccati_tracking(Qf, Q, R, A, B, C, horizon)
    
    P(:, :, horizon) = C' * Qf * C;
    V = C' * Q * C;
    
    % P matrices computation
    for t = horizon : -1 : 2
        Pt = P(:, :, t);
        P(:, :, t - 1) = A' * Pt * A - A' * Pt * B * ...
            (R + B' * Pt * B)^(-1) * B' * Pt * A + V;
    end
    
    %L term computation
    for t = horizon - 1 : -1 : 1
        Pt_1 = P(:, :, t + 1);
        L(:, t) = (R + B' * Pt_1 * B)^(-1) * B' * Pt_1 * A;
    end
end