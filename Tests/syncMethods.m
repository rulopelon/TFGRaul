clear,clc,close all force;
parameters
global PREFIX
global symbol_length
global CARRIERS 
global NFFT

[a,b] = OFDMModV2(10);

b = b.';
%[correlation] = conv(fliplr(conj(b(1:(ceil(symbol_length*3))))),b(1:symbol_length*3));
y = [b; zeros(8192,1)].*conj([zeros(8192,1); b]);
% Suma
z = conv(y.',ones(256,1));
figure
plot(1:length(z),abs(z))

%% 4.4.1
[indexes, pilots] = getContinuousPilots();
m = zeros(8192,1);

for i = indexes
   m(i+(NFFT-CARRIERS-1)/2,1) = pilots(i+1);
end        
pilots = ifft(ifftshift(m));

z_2 = zeros(length(b)+length(pilots),1);
duration = length(b)-length(pilots);

for delay = 0:1:duration
    y  = conj(b(delay+1:delay+length(pilots))).*pilots;
    z_2(delay+1) = sum(y);
end
figure
plot(abs(z_2))
%% 4.4.2
[indexes, pilots] = getContinuousPilots();
m = zeros(8192,1);

for i = indexes
   m(i+(NFFT-CARRIERS-1)/2,1) = pilots(i+1);
end        
pilots = ifft(ifftshift(m));

r =[zeros(8192,1);b];
r_2 = [b;zeros(8192,1)];
b_2 = conj(r).*r_2;

z_3 = zeros(length(r)+length(pilots),1);
duration = length(b)-length(pilots)-1;

for delay = 0:1:duration
     y  = conj(r(delay+1:delay+length(pilots))).*pilots;
     z_3(delay+1) = sum(y);
end

figure
plot(abs(z_3))
