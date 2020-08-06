%% [struct] = load_input(inputPath)
% video - struct
% 

%edited by Manu Ramesh - for VADL
%takes in deer and empty stack

%function [video_id, video] = load_video_file_vadl(file)
function [video_id, nChopFrames, video] = load_video_file_vadl(fileChop, fileCommon, chopLength, bgLength)

persistent v_id;
if isempty(v_id)
    v_id = 0;
else
    v_id = v_id + 1;
end

video_id = v_id; %passing the video id out
chopLength = str2num(chopLength) %making the string a number
bgLength   = str2num(bgLength)   %making the string a number

% displog('Checking input file extension...');
input_extension = get_file_extension(fileChop);
%constraint = 0;

if(strcmp(input_extension,'mat')) %Manu - we will not be using this section 
  % video2mat('dataset/demo.avi', 'dataset/demo.mat');
  % file = 'dataset/demo.mat';
  % displog('Loading data...');
  load(fileChop);
else
  % displog('Reading movie file...');
  
  %video = mmread(file,[],[],false,true);
  
  %by Manu
  %read chopLength frames from deer video and (all, now bgLength number of) frames from empty video,
  %create a stack and pass to the calling function
  
  xyloObj_chop = VideoReader(fileChop);
  xyloObj_common = VideoReader(fileCommon);
  
  %the widht and height will be same for both videos, using any is fine
  vidWidth = xyloObj_chop.Width;
  vidHeight = xyloObj_chop.Height;
  k = 0;
  nChopFrames = 0;
  disp(["video id = "  v_id  ", lower bound = "  ((v_id * chopLength) + 1)  ", upper bound = "  (((v_id+1) * chopLength) + 1)]);
  
  while hasFrame(xyloObj_chop) %deer
    k = k+1;
 
    %disp(["loading deer file, k = " k]);

    %if (k >= ((str2num(v_id) * str2num(chopLength)) + 1)) && (k < (((str2num(v_id)+1) * str2num(chopLength)) + 1))
    if (k >= ((v_id * chopLength) + 1)) && (k < (((v_id+1) * chopLength) + 1))
    	disp(["loading deer file, k = " k]);
        video.frames(nChopFrames+1).cdata = readFrame(xyloObj_chop);
        nChopFrames = nChopFrames + 1;
    else
        readFrame(xyloObj_chop); %just read frame, do not store it, this increments the internal frame counter
	%disp('Skipping deer frames');
    end
  end
      
  k = 0; 
  %if no deer frame is loaded (nChopFrames == 0), don't bother to load bg frames
  while hasFrame(xyloObj_common) && (nChopFrames ~= 0) && (k < bgLength) %empty
    k = k+1;
    %disp(["loading empty file, k = " k ", Cumulative frame count = " k+nChopFrames]);
    video.frames(k+nChopFrames).cdata = readFrame(xyloObj_common); %write to k+nChopFrames th frame, writing to kth frame overwrites the deer frames!
  end

  disp("Number of empty frames loaded = " + num2str(k));

  %video.nrFramesTotal = k;
  video.nrFramesTotal = k + nChopFrames;
  
  video.width  = vidWidth;
  video.height = vidHeight;

%   if(constraint)
%     if(video.width > 320 || video.height > 320)
%       width = round(video.width/2);
%       height = round(video.height/2);
%       [~,n] = size(video.frames);
%       for i = 1:n
%         video.frames(i).cdata = imresize(video.frames(i).cdata, [height width]);
%       end
%       video.width = width;
%       video.height = height;
%     end
%   end
  
  bytesize(video);
  % movie(video.frames);
  
  % For debug
  % show_video(video);
  
  %warning('on','all');
end
%displog('OK');

end
