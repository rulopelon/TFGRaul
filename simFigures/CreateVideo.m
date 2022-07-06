%% Code for generating a video from a secuence of images
clc,clear
imageNames = dir(fullfile('2DImages','*.jpg'));

imageNames = {imageNames.name}';
outputVideo = VideoWriter(fullfile('2DImages','2Dvideo'));
outputVideo.FrameRate = 20;
listNames = natsort(imageNames);
open(outputVideo)
for ii = 1:length(listNames)
   img = imread(fullfile('2DImages',listNames{ii}));
   writeVideo(outputVideo,img)
end

close(outputVideo)