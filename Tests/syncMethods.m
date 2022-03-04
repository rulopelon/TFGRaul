clear,clc,close all force;
load("variables.mat","symbol_length","CARRIERS","NFFT","PREFIX")
prefix_length = NFFT*PREFIX;


[a,b] = OFDMModV2(10);

n = 0:1:length(b)-1;
shift =30/length(b);    
b = b.*exp(1i*shift*n);

b = b.';
b = [zeros(1000,1);b];
disp("Expected maximum at 14216 (9216+5000)")

y = [b; zeros(NFFT,1)].*conj([zeros(NFFT,1); b]);
% Suma
z = conv(y.',ones(prefix_length,1));
figure
plot(1:length(z),abs(z))

%% 4.4.1
[indexes, pilots] = getContinuousPilots();
m = zeros(8192,1);
for i = indexes
   m(i+(NFFT-CARRIERS-1)/2,1) = pilots(i+1);
end        
pilots = ifft(ifftshift(m));

z_2 = conv(conj(b),flip(pilots));

figure
plot(abs(z_2))
title("Pilots in time domain")
%% 4.4.2

[indexes, pilots] = getContinuousPilots();
m = zeros(8192,1);

for i = indexes
   m(i+(NFFT-CARRIERS-1)/2,1) = pilots(i+1);
end        
pilots = ifft(ifftshift(m));

r =[zeros(NFFT,1);b];
r_2 = [b;zeros(NFFT,1)];
b_2 = conj(r+r_2);
pilots = flip(pilots);
pilots_shortened = pilots(1:prefix_length);
z_3 = abs(conv(b_2,pilots));
z_4 = abs(conv(b_2,pilots_shortened));

figure
subplot(2,1,1)
plot(z_3)
title("Length of pilots: 8192")

subplot(2,1,2)
plot(z_4)
title("Length of pilots: 256")

