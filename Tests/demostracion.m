clear,clc,close all force;
global PREFIX
global symbol_length

[a,b] = OFDMModV2(3);


%[correlation] = conv(fliplr(conj(b(1:(ceil(symbol_length*3))))),b(1:symbol_length*3));
[correlation,lags] = xcorr(b,b);
figure
plot(lags,abs(correlation))