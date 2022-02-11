
%% Generación OFDM super simple

% Generación aleatoria de símbolos M-QAM
M = 64;
num_symb = 10;

A = floor(rand(8192,num_symb)*0.99*sqrt(M))-sqrt(M)/2+0.5 + 1j*(floor(rand(8192,num_symb)*0.99*sqrt(M))-sqrt(M)/2+0.5);
A = A/(sqrt(2)*(sqrt(M)/2-0.5));

% Plot constelación
figure
plot(real(A(:)), imag(A(:)), 'ob', 'MarkerFaceColor', 'b')

% Para simular los pilotos 1 de cada 10 portadoras se ponen a un valor BPSK fijo
A(1:50:end,1) = round(rand(1))*2-1;
for i = 1:num_symb
    A(1:10:end,i) = A(1:10:end,1);
end

% Se ponen a cero las portadoras que no se utilizan
A(1:256,:) = 0;
A(end-256+1:end,:) = 0;
% Se crea la señal OFDM
Y = ifft(ifftshift(A,1),8192,1);
% Se añade el prefijo cíclico
Y = [Y((end-255):end,:);Y];
% Se concatenan todos los símbolos
s = Y(:);

%% Sincronismo de símbolo

y = [s; zeros(8192,1)].*conj([zeros(8192,1); s]);
z = conv(y.',ones(1,256));

figure
plot(1:length(z),abs(z))