%% Code for generating a video from a secuence of images
clc,clear
imageNames = dir(fullfile('simFigures','*.jpg'));

imageNames = {imageNames.name}';
outputVideo = VideoWriter(fullfile('simFigures','radarRepresentation'));
outputVideo.FrameRate = 20;
listNames = natsort(imageNames);
open(outputVideo)
for ii = 1:length(listNames)
   img = imread(fullfile('simFigures',listNames{ii}));
   writeVideo(outputVideo,img)
end

close(outputVideo)