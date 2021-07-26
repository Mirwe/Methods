%It is a function that computes the total processing time for a given set of jobs
%It is used in the algorithmDP.m file

function time = totalProcessingTime(jobs, p)
    temp = 0;
    for i = 1 : length(jobs)
        temp = temp + p(jobs(i));
    end
    time = temp;
end