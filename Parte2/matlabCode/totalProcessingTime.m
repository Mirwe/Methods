function time = totalProcessingTime(jobs, p)
    temp = 0;
    for i = 1 : length(jobs)
        temp = temp + p(jobs(i));
    end
    time = temp;
end