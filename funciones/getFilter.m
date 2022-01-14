function h = getFilter(M,L)
%Función para la creación de un filtro de para la interpolación correcta de
%la señal, empleando el método de Parks-McClellan
%Autor: Carlos García de la Cueva
%Modificado: Raúl Gonzále Gómez
    global PLOT
    global NFFT
    global CARRIERS
    
    % Rizado de la banda de paso en dB
    Rp = 0.05;
    rp = 10^(Rp/20) - 1; 
    % Atenuación de la banda eliminada en dB
    Att = 80;
    att = 10^(-Att/20);
    % Frecuencia de corte del filtro (caida a -3 dB)
    fc = 1/(2*M);
    
    % Banda de Transición
    delta_f = ((NFFT-CARRIERS)/2);  % Se escoge delta para
    Df = (delta_f/NFFT)/M;
    
    Nmin = (-10*log10(rp*att)-13)/(14.6*Df) + 1;
    amp = [1 1 0 0];
    % Eje de frecuencias
    freq = [0 fc fc+Df 0.5];
    % Diseño del filtro 
    h = firpm(ceil(Nmin),freq*2,amp,[att/rp, 1]); % L frecuencia se multiplica por 2 porque hay que introducirlo respecto a pi
    % Cálculo de la respuesta en frecuencia del filtro
    H = fftshift(fft(h,NFFT));
    H = H.*L;
    h = ifft(ifftshift(H));

    if PLOT
        % Visualización gráfica de la respuesta en módulo
        figure;
        a1 = axes;
        plot(a1,linspace(-0.5,0.5,length(H)),20*log10(abs(H)))
        xlabel(a1,'Normalized Frequency','Interpreter',"latex")
        ylabel(a1,'dB','Interpreter',"latex")
        title(a1,'$|H(e^{jw})|^2$',"Interpreter",'latex')
        grid(a1,'on')
    end
    
    
end

