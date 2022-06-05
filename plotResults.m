function plotResults(correlation_matrix)
    load("variables.mat","Fs_used","BATCH_SIZE")

    Fs_analysis = Fs_used/BATCH_SIZE;
    doppler_axis = linspace(-0.5*Fs_analysis,0.5*Fs_analysis,512);
    range_axis= 1:1:BATCH_SIZE;
    [X,Y] = meshgrid(range_axis,doppler_axis);
    f = figure;
    representation = surf(X,Y,(abs(correlation_matrix.')),'EdgeColor','none')
    xlabel('Delay')
    ylabel('Doppler')
    zlabel('Correlation')
    ax = gca;
    ax.Color = 'white';
    colormap hsv
    title("CAF representation")
    
    image(representation.CData,'CDataMapping','scaled')
    a = 2
%         nombre = input("Introduzca el nombre de la figura");
%         guardaFiguraPaper(nombre,f,ax,'-djpeg',0)



end

