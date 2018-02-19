clear all;
close all;
% **********************
% RBCMC TP1 EX2
% **********************

% set params for mccgenerate
Alpha=0.65 ;
Beta=0.02 ;
Gamma=0.95 ;

T = 10000000 ;
B = [1, 0;
     0, 1];
% transition matrix
A = [0.87, 0.13;
     0.15, 0.85];

% generate empirical
% 0:non-pluie, 1:pluie
[sequence,etats] = mccgenerate(T,A,B,'Symbols',[0,1],'Statenames',[0,1]); 

% plot the random sequence of states
% x range: 0:100000, (values either 0, 1, 2)
% subplot(2,1,1)
% bar(etats)

% plot the sequence of emission symbols
% x range: 0:100000, (values either 0 or 1)
% subplot(2,1,2)
% plot(sequence)

% calc % of empirical
count_rain = sum(sequence==1)
count_dry = sum(sequence==0)
pcent_rain = (count_rain / length(sequence)) * 100
pcent_dry = (count_dry / length(sequence)) * 100


% % print values of transition matrix multiplied by itself as n->inf
% A^T
% % check if result is different for 'odd numbered inf' for ergodique case
% A^(T+1)


%------------------------------------------------
% Calcul des pdf des durées de pluie et de sécheresse à partir
% du support de la pluie (1 : Non pluie, 2 : pluie)
% En entrée : vecteur contenant la série du support de pluie
% En sortie : pdf des durée de sécheresse, de pluie, durées
% v2.0

% calc pdf of empirical
[pdfsec,pdfpluie,dureeS,dureeP]=duree(sequence);
 
% get real data
RR5MN = matfile('RR5MN.mat')
% get pdf of real data
[rr_pdfsec,rr_pdfpluie,rr_dureeS,rr_dureeP]=duree(RR5MN.Support);

% calc % of real data
count_rain = sum(RR5MN.Support==2)
count_dry = sum(RR5MN.Support==1)
pcent_rain = (count_rain / length(RR5MN.Support)) * 100
pcent_dry = (count_dry / length(RR5MN.Support)) * 100



figure
% **WET****************************
% plot real data
semilogy(rr_dureeP, rr_pdfpluie, 'LineWidth',2);
hold on;

% calc pdf using formula P(d=d) = pq^d-1 = (1-alpha) * alpha^d-1
% pdfpluie_theoretical=pdfpluie_theoretical(Alpha, 5)

% plot empirical
semilogy(dureeP, pdfpluie, 'LineWidth',2);
hold off;

title('PDF of Real & Empirical data - RAINY DAYS (Two States Only)', 'FontSize', 18);
xlabel('Duration of consecutive Rain Days (Days)', 'FontSize', 16);
ylabel('PDF (semilog scale)', 'FontSize', 16);
grid on;
legend('Real Data','Empirical')


figure
% **DRY****************************
semilogy(rr_dureeS, rr_pdfsec, 'LineWidth',2);
hold on;

% calc dry theoretical
% T = 109 ;
pdflist_dry = [];
for d = dureeS
    p = Beta;
    q = (1-Beta).^(d);
    pdf = p*q;
    pdflist_dry=[pdflist_dry;pdf]
end

% plot dry on semi-log scale
% x = duree of rain
% y = pdf (theoretcial, and pdf empirical (from duree func)
% semilogy(dureeS, pdflist_dry, 'LineWidth',2);

% do the same for dry days - plot empirical
semilogy(dureeS, pdfsec, 'LineWidth',2);
hold off;

title('PDF of Real Data and Empirical - DRY DAYS (Two States Only)', 'FontSize', 18);
xlabel('Duration of consecutive Dry Days (Days)', 'FontSize', 16);
ylabel('PDF (semilog scale)', 'FontSize', 16);
grid on;
legend('Real Data','Empirical')



% ***********************
% HMM train to find better A and B
% ***********************
% function [guessTR,guessE,logliks] = mcctrain(seqs,guessTR,guessE,varargin)

[A_est,B_est] = mcctrain(RR5MN.Support,A,B)

% load pretrained for speed
% A_est = matfile('A_est.mat')
% B_est = matfile('B_est.mat')

% generate NEW empirical
% 0:non-pluie, 1:pluie
[sequence_est,etats_est] = mccgenerate(T,A_est,B_est,'Symbols',[0,1],'Statenames',[0,1]); 

% calc pdf of empirical
[pdfsec,pdfpluie,dureeS,dureeP]=duree(sequence_est);

figure
% **WET****************************
% plot real data
semilogy(rr_dureeP, rr_pdfpluie, 'LineWidth',2);
hold on;

% calc pdf using formula P(d=d) = pq^d-1 = (1-alpha) * alpha^d-1
% pdfpluie_theoretical=pdfpluie_theoretical(Alpha, 5)

% plot empirical
semilogy(dureeP, pdfpluie, 'LineWidth',2);
hold off;

title('PDF of Real & NEW Empirical data - RAINY DAYS (Two States Only)', 'FontSize', 18);
xlabel('Duration of consecutive Rain Days (Days)', 'FontSize', 16);
ylabel('PDF (semilog scale)', 'FontSize', 16);
grid on;
legend('Real Data','NEW Empirical')


figure
% **DRY****************************
% plot real data
semilogy(rr_dureeS, rr_pdfsec, 'LineWidth',2);
hold on;

% calc pdf using formula P(d=d) = pq^d-1 = (1-alpha) * alpha^d-1
% pdfpluie_theoretical=pdfpluie_theoretical(Alpha, 5)

% plot empirical
semilogy(dureeS, pdfsec, 'LineWidth',2);
hold off;

title('PDF of Real & NEW Empirical data - DRY DAYS (Two States Only)', 'FontSize', 18);
xlabel('Duration of consecutive Dry Days (Days)', 'FontSize', 16);
ylabel('PDF (semilog scale)', 'FontSize', 16);
grid on;
legend('Real Data','NEW Empirical')
