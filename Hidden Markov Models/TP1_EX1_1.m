clear all;
close all;
% **********************
% RBCMC TP1 EX1 and EX2
% **********************

% set params for mccgenerate
Alpha=0.65 ;
Beta=0.02 ;
Gamma=0.95 ;
T = 10000000 ;
B=eye(3);
% transition matrix
A = [0, Gamma, 1-Gamma;
     0, 1-Beta, Beta;
     0, 1-Alpha, Alpha];

% 0:init, 1:non-pluie, 2:pluie
[sequence,etats] = mccgenerate(T,A,B,'Symbols',[0,1,2],'Statenames',[0,1,2]); 

% plot the random sequence of states
% x range: 0:100000, y range: 1:2 (values either 1 or 2)
% subplot(2,1,1)
% bar(etats)

% plot the sequence of emission symbols
% x range: 0:100000, y range: 1:2 (values either 1 or 2)
% subplot(2,1,2)
% plot(sequence)

% print values of transition matrix multiplied by itself as n->inf
A^T
% check if result is different for 'odd numbered inf' for ergodique case
A^(T+1)


%------------------------------------------------
% Calcul des pdf des durées de pluie et de sécheresse à partir
% du support de la pluie (1 : Non pluie, 2 : pluie)
% En entrée : vecteur contenant la série du support de pluie
% En sortie : pdf des durée de sécheresse, de pluie, durées
% v2.0
[pdfsec,pdfpluie,dureeS,dureeP]=duree(sequence);

RR5MN = matfile('RR5MN.mat')
[rr_pdfsec,rr_pdfpluie,rr_dureeS,rr_dureeP]=duree(RR5MN.Support);

figure
% **WET****************************
% plot real
semilogy(rr_dureeP, rr_pdfpluie, 'LineWidth',2);
hold on;

% calc pdf using formula P(d=d) = pq^d-1 = (1-alpha) * alpha^d-1
% pdfpluie_theoretical=pdfpluie_theoretical(Alpha, 5)

pdflist_rain = [];
for d = dureeP
    p = 1-Alpha;
    q = Alpha.^(d);
    pdf = p*q;
    pdflist_rain=[pdflist_rain;pdf]
end

% plot theor on semi-log scale
% x = duree of rain
% y = pdf (theoretcial, and pdf empirical (from duree func)
% semilogy(dureeP, pdflist_rain, 'LineWidth',2);

% plot empirical
semilogy(dureeP, pdfpluie, 'LineWidth',2);
hold off;

title('PDF of Empirical, Theoretical and Observed - RAINY DAYS', 'FontSize', 18);
xlabel('Duration of consecutive Rain Days (Days)', 'FontSize', 16);
ylabel('PDF (semilog scale)', 'FontSize', 16);
grid on;
legend('Real Data', 'Theoretical', 'Empirical')


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

title('PDF of Empirical, Theoretical and Observed - DRY DAYS', 'FontSize', 18);
xlabel('Duration of consecutive Rain Days (Days)', 'FontSize', 16);
ylabel('PDF (semilog scale)', 'FontSize', 16);
grid on;
legend('Real Data', 'Theoretical', 'Empirical')

