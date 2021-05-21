%function to compute p riccati matrix and k control matrix for LQR
%A,B matrixes of linear state dynamics, 
%Q, Qf cost of the state; R cost of the control;
%N number of time intervals; N+1 samples

function  [P, K]=pk_riccati(A,B,C,Q,Qf,R,N)

V=C'*Q*C;
P(:,:,N+1)=C'*Qf*C;
%E=B*inv(R)*B';

for i=N:-1:1
P(:,:,i)=A'*P(:,:,i+1)*A-A'*P(:,:,i+1)*B*...
         ((R+B'*P(:,:,i+1)*B)\B')*P(:,:,i+1)*A +V;
%P(:,:,i)=A'*P(:,:,i+1)*inv(eye(size(A,1))+E*P(:,:,i+1))*A+V;
end

for i=1:N
    K(:,:,i)=((R+B'*P(:,:,i+1)*B)\...
               B')*P(:,:,i+1)*A;
end
end

%function to compute p riccati matrix and k control matrix for LQR
%A,B matrixes of linear state dynamics, 
%Q, Qf cost of the state; R cost of the control;
%N number of time intervals; N+1 samples

% function  [P, K]=pk_riccati(A,B,C,Q,Qf,R,N)
% 
% V=C'*Q*C;
% P(:,:,N+1)=C'*Qf*C;
% E=B*inv(R)*B';
% 
% for i=N:-1:1
% P(:,:,i)=A'*P(:,:,i+1)*A-A'*P(:,:,i+1)*B*...
%          (inv(R+B'*P(:,:,i+1)*B))*B'*P(:,:,i+1)*A +V;
% P(:,:,i)=A'*P(:,:,i+1)*inv(eye(size(A,1))+E*P(:,:,i+1))*A+V;
% end
% 
% for i=1:N
%     K(:,:,i)=inv(R+B'*P(:,:,i+1)*B)*...
%                B'*P(:,:,i+1)*A;
% end
% end

