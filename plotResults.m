function plotResults(correlation_matrix)
    load("variables.mat","Fs_used","BATCH_SIZE")

    Fs_analysis = Fs_used/BATCH_SIZE;
    doppler_axis = linspace(-0.5*Fs_analysis,0.5*Fs_analysis,512);
    range_axis= 1:1:BATCH_SIZE;
    [X,Y] = meshgrid(range_axis,doppler_axis);
    f = figure;
    surf(X,Y,20*log10((abs(correlation_matrix.'))),'EdgeColor','none')
    xlabel('Delay')
    ylabel('Doppler')
    zlabel('Correlation')
    ax = gca;
    ax.Color = 'white';
    colormap jet
    title("CAF representation")
    
%     figure
%     image(representation.CData,'CDataMapping','scaled')
    
    %nombre = input("Introduzca el nombre de la figura");
    nombre = load("iteration.mat");
    iteration = nombre.iteration+1;
    nombreguardar = ['simFigures/' num2str(iteration)];
    guardaFiguraPaper(nombreguardar,f,ax,'-djpeg',0)
    close all
    save("iteration.mat","iteration")
    a = 2;


end

