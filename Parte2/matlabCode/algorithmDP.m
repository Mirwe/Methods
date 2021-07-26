clear;
clc;

%% Definition of the problem data
% five different jobs to be scheduled
num_jobs = 5;
jobs = (1 : num_jobs)';

%processing time for each job
p = [4 2 6 3 5]';

%due date for each job
d = [7 9 9 6 12]';

% weights for each job
w = [1.5 1.5 1.5 1 1]';

% precedence constraints
% J1 -> J2
% J1 -> J3
% J4 -> J5

%% Definition of the stages
% Here I get all the possible combination of the stages
X0 = 0;
for i = num_jobs : -1 : 1
    tempX{i} = nchoosek(jobs, i);
end

% Here I delete the combinations that do not satisfy the constraints
for i = length(tempX) : -1 : 1
    k = 1;
    for j = 1 : length(tempX{i}(:, 1))
        if ismember(1, tempX{i}(j, :)) || ismember(4, tempX{i}(j, :))
            X{i}(k, :) = tempX{i}(j, :);
            k = k + 1;
            if (i ~= 1)
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
    end
end

%% Backward phase

% stage k = 5
%no decisions to take

% optimal cost
Go{num_jobs} = 0;

% stages k = 4 - 3 - 2 - 1
for k = num_jobs - 1 : -1 : 1
    G{k} = Inf(length(X{k}(:, 1)), length(X{k + 1}(:, 1)));
    for i = 1 : length(X{k}(:, 1))
        st = totalProcessingTime(X{k}(i, :), p);
        for j = 1 : length(X{k + 1}(:, 1))
            if ismember(X{k}(i, :), X{k + 1}(j, :))
                %job to be scheduled from set i to j at stage k to k+1
                job(:, j) = setdiff(X{k + 1}(j, :), X{k}(i, :));
                
                %tardiness for the set i
                tardiness = max((st + p(job(:, j)) - d(job(:, j))), 0);
                
                %costs for each set i to j
                G{k}(i, j) = Go{k + 1}(j) + w(job(:, j)) * tardiness;
            end
        end
        
        %optimal cost for set i at stage k to k+1
        [Go{k}(i), U{k}(i, :)] = min(G{k}(i, :));
        job_{k}(i) = job(:, U{k}(i, :));
    end
end

% stage k = 0
for i = length(X{1}(:, 1)) : -1 : 1
    tardiness = max((st + p(X{1}(i)) - d(X{1}(i))), 0);
    G0(i) = Go{1}(i) + w(X{1}(i)) * tardiness;
end

[Go0, U0] = min(G0);
job_0 = X{1}(U0, :);

%% Forward phase
parents(1, 1) = U0;
path(1, 1) = job_0;

for i = 1 : num_jobs - 1
    parents(1, i + 1) = U{i}(parents(1, i), :);
    
    path(1, i + 1) = job_{i}(parents(1, i));
end

fprintf("Optimal schedule:\n");
for i = 1 : num_jobs - 1
    fprintf("Job%i -> ", path(1, i));
end

fprintf("Job%i \n\n", path(1, num_jobs));

fprintf("With a weigth tardiness of: %i \n", Go0);