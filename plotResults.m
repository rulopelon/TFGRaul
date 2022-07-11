function plotResults(correlation_matrix)
    load("variables.mat","Fs_used","BATCH_SIZE","PROPAGATION_VELOCITY","Fc","EMITTER_POSITION","RECIEVER_POSITION","Vmax","TARGET1_UNITARY_VECTOR")

    Fs_analysis = Fs_used/BATCH_SIZE;
    doppler_axis = linspace(-0.5*Fs_analysis,0.5*Fs_analysis,512);
    velocity_axis = doppler_axis.*(PROPAGATION_VELOCITY/Fc);
    range_axis= 1:1:BATCH_SIZE;
    distance_axis = range_axis.*(1/Fs_used)*PROPAGATION_VELOCITY;
    [X,Y] = meshgrid(distance_axis,velocity_axis);

    variables = load("iteration.mat");
    iteration = variables.iteration+1;
    TARGET_POSITION = variables.TARGET_POSITION;

    f = figure;
    representation = surf(X,Y,20*log10((abs(correlation_matrix.'))),'EdgeColor','none');
    xlabel('Distancia m')
    ylabel('Velocidad m/s')
    zlabel('Correlacion dB')
    ax = gca;
    ax.Color = 'white';
    colormap jet
    title("CAF representation")

    nombreguardar = ['simFigures/' num2str(iteration)];
    nombreguardar = "shifted";
    guardaFiguraPaper(nombreguardar,f,ax,'-djpeg',0)
    colorData = representation.CData(:,1:200);
    close

    f2 = figure;
    plot3(EMITTER_POSITION(1)/1000,EMITTER_POSITION(2)/1000,EMITTER_POSITION(3)/1000,'s')
    hold on
    plot3(RECIEVER_POSITION(1)/1000,RECIEVER_POSITION(2)/1000,RECIEVER_POSITION(3)/1000,'s')
    pitch = rad2deg(acos(dot([1,0,0],TARGET1_UNITARY_VECTOR)/sqrt(sum(TARGET1_UNITARY_VECTOR.^2))));
    c130(TARGET_POSITION(1)/1000,TARGET_POSITION(2)/1000,TARGET_POSITION(3)/1000,'scale',0.04,'z',1,'yaw',-90,'pitch',pitch)
    %Dummy plot
    plot3(0,0,6)
    clear xlim
    clear ylim
    clear zlim
    xlim([-1 TARGET_POSITION(2)/1000+10])
    ylim([-1 TARGET_POSITION(2)/1000+10])
    zlim([0 6])
    ax = gca;
    ax.Color = 'white';
    grid on
    title("Scenery representation")

    nombreguardar = ['sceneryFigures/' num2str(iteration)];
    print(nombreguardar,'-djpeg')    
    close
    
    
    figure
    imagen = imagesc(colorData,'CDataMapping','scaled');
    ax = gca;
    ax.YTick =linspace(1,512,30);
    ax.YTickLabel =linspace(-300,300,30) ;
    ax.XTick =1:20:200;
    ax.XTickLabel =distance_axis(1:20:200) ;

    xlabel("Distancia m");
    ylabel('Velocidad m/s')

    nombreguardar = ['2DImages/' num2str(iteration) '.jpg'];
    saveas(imagen,nombreguardar)
    close
    %nombre = input("Introduzca el nombre de la figura");
   
    save("iteration.mat","iteration","-append")
end

