
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% 1) Crear el modelo cinemático de los blancos (MRU)

% 1.1) Definir la posición inicial x_o (vector de 3 posiciones)
% 1.2) Definir el vector de velocidad (vector de 3 posiciones)

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% 2) Crear la forma de onda transmitida de longitud L (muestras)

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% 3) Iniciar el bucle de procesado 
%
%   P = bloques de procesao coherente
%   for k=1:P
%       3.1) Mover el blanco a la posición: x = x_o + k*T*v_o;
%       donde T es el periodo de procesado coherente en segundos.
%       3.2) Calcular retardo de propagación desde el tx al blanco y de
%       vuelta al rx.
%       3.3) Calcular la desviación doppler bi-estática
%       3.4) Crear la señal radar recibida: señal original retardada y
%       desplazada en frecuencia a la frecuencia doppler calculada.
%       (aplicar retardo en el dominio de la frecuencia)
%       3.5) Calcular la función de ambigüedad cruzada entre se la señal de
%       referencia y los ecos recibidos.
%   end