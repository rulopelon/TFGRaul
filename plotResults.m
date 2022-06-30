function plotResults(correlation_matrix)
    load("variables.mat","Fs_used","BATCH_SIZE","PROPAGATION_VELOCITY","Fc","EMITTER_POSITION","RECIEVER_POSITION")

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
    surf(X,Y,20*log10((abs(correlation_matrix.'))),'EdgeColor','none')
    xlabel('Delay m')
    ylabel('Velocity m/s')
    zlabel('Correlation dB')
    ax = gca;
    ax.Color = 'white';
    colormap jet
    title("CAF representation")

    nombreguardar = ['simFigures/' num2str(iteration)];
    guardaFiguraPaper(nombreguardar,f,ax,'-djpeg',0)
    
    close 
    f2 = figure;
    plot3(EMITTER_POSITION(1)/1000,EMITTER_POSITION(2)/1000,EMITTER_POSITION(3)/1000,'s')
    hold on
    plot3(RECIEVER_POSITION(1)/1000,RECIEVER_POSITION(2)/1000,RECIEVER_POSITION(3)/1000,'s')
    plot3(TARGET_POSITION(1)/1000,TARGET_POSITION(2)/1000,TARGET_POSITION(3)/1000,'s')
    %Dummy plot
    plot3(0,0,5500)
    clear xlim
    clear ylim
    clear zlim
    xlim([-10 TARGET_POSITION(1)/1000+10])
    ylim([-1 TARGET_POSITION(2)/1000+10])
    zlim([0 5500])
    ax = gca;
    ax.Color = 'white';
    grid on
    title("Scenery representation")

    nombreguardar = ['sceneryFigures/' num2str(iteration)];
    guardaFiguraPaper(nombreguardar,f2,ax,'-djpeg',0)
    close 
    
    
    save("iteration.mat","iteration","-append")
%     figure
%     image(representation.CData,'CDataMapping','scaled')
    
    %nombre = input("Introduzca el nombre de la figura");
   
   
    
    a = 2;


end

