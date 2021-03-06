function  plotElement(tp,position,velocity,type)
    %Function to add an element to the plot of the simulation
    if strcmp(type,'Avion')
        plotter = platformPlotter(tp,'DisplayName',type);     
    elseif strcmp(type,'Emisor') || strcmp(type,'Receptor')
        plotter = platformPlotter(tp,'DisplayName',type,'Marker','s');
    else
        plotter = platformPlotter(tp,'DisplayName',type,'Marker','d');
    end
    plotPlatform(plotter, position, velocity);

end

