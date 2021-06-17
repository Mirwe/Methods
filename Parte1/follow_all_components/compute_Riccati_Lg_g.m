function [L, Lg, g] = compute_Riccati_Lg_g(Q, R, Qf, A, B, z, N)
    
    dim_state = size(A,1);
    I = eye(dim_state);
    
    % Compute the P matrix (Riccati matrix)
    P = zeros(dim_state, dim_state, N);
    P(:,:,end) = Qf;
    for t = N-1 : -1 : 1
        P(:,:,t) = Q + A' * P(:,:,t+1) *...
            ((I + (B*(R\B')) * P(:,:,t+1)) \ A);
    end
    
    
    % Compute L matrix
    for t = 1 : N-1
        L(:,:,t) = -(R + B' * P(:,:,t+1) * B) \ (B' * P(:,:,t+1) * A);
    end
    
    W = I' * Q;
    E = B * (R\B)';
    
    % g term computation
    g(:, :, N) = I' * Qf * z(:, N);
    for i = N - 1 : -1 : 1
        g(:, :, i) = A' * (eye(size(A, 1)) - ...
            (inv(P(:, :, i + 1)) + E)\E) * g(:, :, i + 1) + W * z(:, i);
    end
    
    % Lg term computation
    for i = N - 1 : -1 : 1
        Lg(:, :, i) = (R + B' * P(:, :, i + 1) * B)\B';
    end
    
end