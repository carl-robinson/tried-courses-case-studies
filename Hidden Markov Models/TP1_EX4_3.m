clear all;
close all;
% **********************
% RBCMC TP1 EX4
% **********************

T = 100000 ;

% emission matrix
% col1 = heads, col2 = tails
B = [0.5, 0.5;
     0.75, 0.25;
     0.25, 0.75];
% transition matrix
A = [0.5, 0.4, 0.1;
     0.3, 0.4, 0.3;
     0.1, 0.2, 0.7];

% generate empirical
[sequence,etats] = mccgenerate(T,A,B,'Symbols',[1,2],'Statenames',[1,2,3]); 

% emission matrix
% col1 = heads, col2 = tails
B_guess = [0.4, 0.6;
           0.7, 0.3;
           0.15, 0.85];
% transition matrix
A_guess = [0.45, 0.35, 0.2;
           0.35, 0.45, 0.2;
           0.2, 0.15, 0.65];

% baum-welch
[A_est,B_est,logliks] = mcctrain(sequence,A_guess,B_guess)


