%% Code for generating a video from a secuence of images
clc,clear
imageNames = dir(fullfile('sceneryFigures','*.jpg'));

imageNames = {imageNames.name}';
outputVideo = VideoWriter(fullfile('sceneryFigures','sceneryVideo'));
outputVideo.FrameRate = 20;
listNames = natsort(imageNames);
open(outputVideo)
for ii = 1:length(listNames)
   img = imread(fullfile('sceneryFigures',listNames{ii}));
   writeVideo(outputVideo,img)
end

close(outputVideo)