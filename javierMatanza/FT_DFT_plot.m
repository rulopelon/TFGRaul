function FT_DFT_plot(F1,F2,Fs,NFFT)

% Signal construction
Ts = 1/Fs;
t = 0:Ts:(NFFT-1)*Ts;  
x1 = sin(2*pi*t*F1);   
x2 = sin(2*pi*t*F2);    


NFFT_over = 2^20;       % oversampling points
X1s = fft(x1,NFFT_over)/length(x1); 
X2s = fft(x2,NFFT_over)/length(x2); 


f=(0:(NFFT_over/2)-1)*Fs/NFFT_over;         
figure
plot(1e-3*f,abs(X1s(1:NFFT_over/2)),'LineWidth',2)    
hold on 
plot(1e-3*f,abs(X2s(1:NFFT_over/2)),'r','LineWidth',2)    
grid on 
xlabel('Freq. [kHz]')
plot(1e-3*f,abs(X2s(1:NFFT_over/2))+abs(X1s(1:NFFT_over/2)),'k--','LineWidth',2)    

legend('Carrier 1','Carrier 2','Sum')

title('Two orthogonal carriers close by')


X1 = fft(x1,NFFT)/length(x1); 
X2 = fft(x2,NFFT)/length(x1); 


f=(0:(NFFT/2)-1)*Fs/NFFT;         
stem(1e-3*f,abs(X1(1:NFFT/2)),'b')    
hold on 
stem(1e-3*f,abs(X2(1:NFFT/2)),'r')   
grid on 
xlabel('Freq. [kHz]')
legend('Carrier 1','Carrier 2','Sum','DFT carrier 1','DFT carrier 2')