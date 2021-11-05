% Script to test the Caf function 
% Fs = 100;
% d = fdesign.lowpass('Fp,Fst,Ap,Ast',200e3,10,0.5,200e3,Fs);
% B = design(d);
% create white Gaussian noise the length of your signal
x = randn(1000,1)*randn(1,1);
% create the band-limited Gaussian noise
% y = filter(B,x);
CAFAnalysis(x,x,1000)