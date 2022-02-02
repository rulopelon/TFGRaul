% Código para guardar figuras con buena relación de aspecto 

function [] = guardaFiguraPaper(nombreFigura,figHandler,axHandler,formato,limits,ticksX,ticksY)

if(limits == 1)
    axHandler.XTickMode = 'manual';
    axHandler.YTickMode = 'manual';
    axHandler.ZTickMode = 'manual';
    axHandler.XLimMode = 'manual';
    axHandler.YLimMode = 'manual';
    axHandler.ZLimMode = 'manual';
    if (~isempty(ticksX))
        axHandler.XTick = ticksX;
    end
    if (~isempty(ticksY))
        axHandler.YTick = ticksY;
    end
else
    axHandler.XTickMode = 'auto';
    axHandler.YTickMode = 'auto';
    axHandler.ZTickMode = 'auto';
    axHandler.XLimMode = 'auto';
    axHandler.YLimMode = 'auto';
    axHandler.ZLimMode = 'auto';
end

figHandler.PaperPosition = [0 0 15 11];
% figHandler.PaperPosition = [0 0 15 9];
% figHandler.PaperPosition = [0 0 25 10];
% figHandler.PaperPosition = [0 0 12 9.6];
% figHandler.PaperPosition = [0 0 8 6.4];

% figHandler.PaperPosition = [0 0 12 8];

% figHandler.PaperPosition = [0 0 20 6];
print(nombreFigura,formato,'-r0')


end