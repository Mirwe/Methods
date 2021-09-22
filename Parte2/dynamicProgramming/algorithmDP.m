clear;
clc;

%% Definition of the problem data
% Five different jobs to be scheduled
num_jobs = 5;
jobs = (1 : num_jobs)';

% Processing time for each job
p = [4 2 6 3 5]';

% Due date for each job
d = [7 9 9 6 12]';

% Weights for each job
w = [1.5 1.5 1.5 1 1]';

% Precedence constraints
% J1 -> J2
% J1 -> J3
% J4 -> J5

%% Definition of the stages
% Get all the possible combination of the states for each stage
X0 = 0;
for i = num_jobs : -1 : 1
    tempX{i} = nchoosek(jobs, i);
end

% Delete all the states that do not satisfy the constraints
for i = length(tempX) : -1 : 1
    k = 1;
    for j = 1 : length(tempX{i}(:, 1))
        
        X{i}(k, :) = tempX{i}(j, :);
        k = k + 1;

        if (ismember(2, X{i}(k - 1, :)) ...
                || ismember(3, X{i}(k - 1, :))) ...
                    && ~ismember(1, X{i}(k - 1, :))
            X{i}(k - 1, :) = [];
            k = k - 1;
        end

        if ismember(5, X{i}(k - 1, :)) ...
                && ~ismember(4, X{i}(k - 1, :))
            X{i}(k - 1, :) = [];
            k = k - 1;
        end     
                
    end
end

%% Backward phase

% Stage k = 5
% No decisions to take

% Optimal cost
Go{num_jobs} = 0;

% Stages k = 4 - 3 - 2 - 1
for k = num_jobs - 1 : -1 : 1
    % inizialization of the costs
    G{k} = Inf(length(X{k}(:, 1)), length(X{k + 1}(:, 1)));
    
    % for each state i at stage k
    for i = 1 : length(X{k}(:, 1))
        
        % Starting time
        st = totalProcessingTime(X{k}(i, :), p);
        
        %for each state j at state k+1
        for j = 1 : length(X{k + 1}(:, 1))
            
            %if from the state i, it's possible to reach state j
            if ismember(X{k}(i, :), X{k + 1}(j, :))
                
                %job to be scheduled from state i to j from stage k to k+1
                job(:, j) = setdiff(X{k + 1}(j, :), X{k}(i, :));
                
                %tardiness for the state i
                tardiness = max((st + p(job(:, j)) - d(job(:, j))), 0);
                
                %costs from state i to state j
                G{k}(i, j) = Go{k + 1}(j) + w(job(:, j)) * tardiness;
            end
        end
        
        % Optimal cost for state i at stage k to k+1
        % U is the position of the next optimal state (at stage k+1) from the stage k and state i
        [Go{k}(i), U{k}(i, :)] = min(G{k}(i, :));
        
        % It is the job to be executed (at state i) in order to reach the
        % optimal state (at stage k+1) from the actual stage k
        nextOptJob{k}(i) = job(:, U{k}(i, :));
    end
end

% Stage k = 0
for i = length(X{1}(:, 1)) : -1 : 1
    st = 0;
    tardiness = max((st + p(X{1}(i)) - d(X{1}(i))), 0);
    G0(i) = Go{1}(i) + w(X{1}(i)) * tardiness;
end

[Go0, U0] = min(G0);
nextOptJob0 = X{1}(U0, :);

%% Forward phase
posNextState(1, 1) = U0;
path(1, 1) = nextOptJob0;

for i = 1 : num_jobs - 1
    %Get the position of the optimal state at the next stage
    posNextState(1, i + 1) = U{i}(posNextState(1, i), :);
    
    %Get the job to execute in order to reach the next optimal state
    path(1, i + 1) = nextOptJob{i}(posNextState(1, i));
end

fprintf("Optimal schedule:\n");
for i = 1 : num_jobs - 1
    fprintf("Job%i -> ", path(1, i));
end

fprintf("Job%i \n\n", path(1, num_jobs));

fprintf("With a weigth tardiness of: %i \n", Go0);