clear all;
close all;
% **********************
% RBCMC TP1 EX4
% **********************

T = 3 ;
% emission matrix
B = [0.5, 0.5;
     0.75, 0.25;
     0.25, 0.75];
% transition matrix
A = [0.5, 0.4, 0.1;
     0.3, 0.4, 0.3;
     0.1, 0.2, 0.7];
 
pi0 = [1, 0, 0];

coinseq = [2, 2, 2]

% generate empirical
% [sequence,etats] = mccgenerate(T,A,B,'Symbols',[1,2],'Statenames',[1,2,3]); 

% decode - forward / backward
[pStates,pSeq, fs, bs, s] = mccdecode(coinseq,A,B);

% f = fs.*repmat(cumprod(s),size(fs,1),1);
% bscale = fliplr(cumprod(fliplr(s)));
% b = bs.*repmat([bscale(2:end), 1],size(bs,1),1);

e = exp(pSeq);
