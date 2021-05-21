%function to compute p riccati matrix and k control matrix for LQR
%A,B matrixes of linear state dynamics, 
%Q, Qf cost of the state; R cost of the control;
%N number of time intervals; N+1 samples

function  [g, Lg]=Lg_xLQT(A,B,C,Q,Qf,R,N,P,z)
%z is the vector to be tracked length N+1, dimension is the one y
W=C'*Q;
E=B*(R\B)';

g(:,:,N+1)=C'*Qf*z(:,N+1);
for i=N:-1:1
g(:,:,i)=A'*(eye(size(A,1))-(pinv(P(:,:,i+1))+E)\E)*g(:,:,i+1)+W*z(:,i);
end

for i=1:N
    Lg(:,:,i)=(R+B'*P(:,:,i+1)*B)\B';
end
end

%function to compute p riccati matrix and k control matrix for LQR
%A,B matrixes of linear state dynamics, 
%Q, Qf cost of the state; R cost of the control;
%N number of time intervals; N+1 samples

% function  [g, Lg]=LgxLQT(A,B,C,Q,Qf,R,N,P,z)
% %z is the vector to be tracked length N+1, dimension is the one y
% W=C'*Q;
% E=B*inv(R)*B';
% 
% g(:,:,N+1)=C'*Qf*z(:,N+1);
% for i=N:-1:1
% g(:,:,i)=A'*(eye(size(A,1))-inv(inv(P(:,:,i+1))+E)*E)*g(:,:,i+1)+W*z(:,i);
% end
% 
% for i=1:N
%     Lg(:,:,i)=inv(R+B'*P(:,:,i+1)*B)*B';
% end
% end

