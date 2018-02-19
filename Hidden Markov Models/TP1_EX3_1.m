clear all;
close all;
% **********************
% RBCMC TP1 EX3
% **********************

T = 10000000 ;
% emission matrix
B = [0.7, 0.3, 0, 0, 0, 0, 0;
     0.1, 0.7, 0.1, 0.1, 0, 0, 0;
     0, 0.15, 0.7, 0, 0.15, 0, 0;
     0, 0.15, 0, 0.7, 0.15, 0, 0;
     0, 0, 0.1, 0.1, 0.7, 0.1, 0;
     0, 0, 0, 0, 0.15, 0.7, 0.15;
     0, 0, 0, 0, 0, 0.3, 0.7];
% transition matrix
A = [0.25, 0.75, 0, 0, 0, 0, 0;
     0.25, 0.25, 0.25, 0.25, 0, 0, 0;
     0, 0.375, 0.25, 0, 0.375, 0, 0;
     0, 0.375, 0, 0.25, 0.375, 0, 0;
     0, 0, 0.25, 0.25, 0.25, 0.25, 0;
     0, 0, 0, 0, 0.375, 0.25, 0.375;
     0, 0, 0, 0, 0, 0.75, 0.25];

% generate empirical
% 0:non-pluie, 1:pluie
[sequence,etats] = mccgenerate(T,A,B,'Symbols',[1,2,3,4,5,6,7],'Statenames',[1,2,3,4,5,6,7]); 

% correct_incorrect = sequence==etats
correct_count = sum(sequence==etats)
correct_pcent = (correct_count / length(sequence)) * 100

% *******************
% loop through all states, starting at i=2
% count all intervals that belong to a sequence of at least 2 the same
temp = 1;
timecount = 0;
inseq = false;
for i = 2:length(etats)
    % if current value and prev value are the same, inc timecount
    if (etats(i) == etats(i-1))
        inseq = true;
        temp = temp + 1;
    elseif inseq == true
        timecount = timecount + temp;
        temp = 1;
        inseq = false;
    end
end

disp('d>=2')
disp(timecount)

% calc percent of time mouse stays in a room for at least 2 mins
pcent_of_time_d2 = (timecount / length(etats)) * 100


% *******************
% loop through all states, starting at i=3
% count all intervals that belong to a sequence of at least 3 the same
temp = 2;
timecount = 0;
inseq = false;
for i = 3:length(etats)
    % if current value and prev value are the same, inc timecount
    if (etats(i) == etats(i-1) && etats(i) == etats(i-2))
        inseq = true;
        temp = temp + 1;
    elseif inseq == true
        timecount = timecount + temp;
        temp = 2;
        inseq = false;
    end
end

disp('d>=3')
disp(timecount)

% calc percent of time mouse stays in a room for at least 2 mins
pcent_of_time_d3 = (timecount / length(etats)) * 100

