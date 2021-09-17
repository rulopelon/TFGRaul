function  plotElement(tp,position,velocity,type)
    %Function to add an element to the plot of the simulation
    plotter = platformPlotter(tp,'DisplayName',type);
    if strcmp(type,'Avion')
        plotPlatform(plotter, position, velocity);
    elseif strcmp(type,'Emisor') || strcmp(type,'Receptor')
        plotPlatform(plotter, position, velocity,'s');
    else
        plotPlatform(plotter, position, velocity,'d');
    end

end

