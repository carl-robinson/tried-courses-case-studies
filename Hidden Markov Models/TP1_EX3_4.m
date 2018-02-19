clear all;
close all;
% **********************
% RBCMC TP1 EX3
% **********************

T = 1000 ;
% emission matrix
B = [0.7, 0.3, 0, 0, 0, 0, 0, 0;
     0.1, 0.7, 0.1, 0.1, 0, 0, 0, 0;
     0, 0.15, 0.7, 0, 0.15, 0, 0, 0;
     0, 0.15, 0, 0.7, 0.15, 0, 0, 0;
     0, 0, 0.1, 0.1, 0.7, 0.1, 0, 0;
     0, 0, 0, 0, 0.15, 0.7, 0.15, 0;
     0, 0, 0, 0, 0, 0.15, 0.7, 0.15;
     0, 0, 0, 0, 0, 0, 0.3, 0.7];
% transition matrix
A = [0.25, 0.75, 0, 0, 0, 0, 0, 0;
     0.25, 0.25, 0.25, 0.25, 0, 0, 0, 0;
     0, 0.375, 0.25, 0, 0.375, 0, 0, 0;
     0, 0.375, 0, 0.25, 0.375, 0, 0, 0;
     0, 0, 0.25, 0.25, 0.25, 0.25, 0, 0;
     0, 0, 0, 0, 0.375, 0.25, 0.375, 0;
     0, 0, 0, 0, 0, 0.1, 0, 0.9;
     0, 0, 0, 0, 0, 0, 0, 1.0];
 
pi0 = [1, 0, 0, 0, 0, 0, 0, 0];

% generate empirical
[sequence,etats] = mccgenerate(T,A,B,'Symbols',[1,2,3,4,5,6,7,8],'Statenames',[1,2,3,4,5,6,7,8]); 

% function [currentState, logP] = mccviterbi(seq,tr,e,varargin)
[currentState, logP] = mccviterbi(sequence,A,B);

% correct_incorrect = sequence==etats
% correct_count = sum(currentState==etats)
% correct_pcent = (correct_count / length(currentState)) * 100

% histogram of states
h = histogram(etats)
pcent = []
vals = h.Values;
for i = 1:8
    pcent(i) = (vals(i) / T) * 100;
end

disp(pcent);

[v,d,w] = eig(A.')





