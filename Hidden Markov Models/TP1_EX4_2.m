clear all;
close all;
% **********************
% RBCMC TP1 EX4
% **********************

T = 3 ;
% emission matrix
% col1 = heads, col2 = tails
B = [0.5, 0.5;
     0.75, 0.25;
     0.25, 0.75];
% transition matrix
A = [0.5, 0.4, 0.1;
     0.3, 0.4, 0.3;
     0.1, 0.2, 0.7];
 
pi0 = [1, 0, 0];

coinseq = [2, 2, 2]

% viterbi
[currentState, logP] = mccviterbi(coinseq,A,B);

% for some reason doesn't work on my computer....

