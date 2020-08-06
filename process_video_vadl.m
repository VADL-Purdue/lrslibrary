%% double process_video(int, int, string, string);
% method_id - string
% algorithm_id - string
% inFile - string
% outFile - string
%
% demos:
% process_video('RPCA', 'FPCP', 'dataset/demo.avi', 'output/demo_out.avi');
% process_video('RPCA', 'FPCP', 'dataset/demo.avi', 'output/demo_out.mat');
% process_video('RPCA', 'FPCP', 'dataset/demo.mat', 'output/demo_out.mat');
% process_video('RPCA', 'FPCP', 'dataset/demo.mat', 'output/demo_out.avi');
%
% unix: 
% ./matlab -nojvm -nodisplay -nosplash -r "process_video('RPCA', 'FPCP', 'dataset/demo.avi', 'output/demo_out.avi');exit;"
% ./matlab -nojvm -nodisplay -nosplash -r "process_video('RPCA', 'FPCP', 'dataset/demo.mat', 'output/demo_out.avi');exit;"
%
% For debug:
% load('output/demo_out.mat');
% showResultsInfo(info);
%
% method_id='RPCA'; algorithm_id='FPCP'; inFile='dataset/demo.avi'; outFile='output/demo_out.avi';
% inFile = 'dataset/ChangeDetection2012/badminton_out.avi';

%edited by Manu Ramesh - for VADL
%inFileChop - video that has the deer images, and needs to be chopped
%inFileCommon - video with the common background images
%chopLength - number of frames of deer video to be processed at a time with
%the stack of empty background images
%bgLength - the number of frames of empty video to be processed with the chopped deer video. Note that these empty images will be the same for every video stack created unlike deer images that are used up one chop length at a time.

function [stats] = process_video_vadl(method_id, algorithm_id, inFileChop, inFileCommon, outFile, chopLength, bgLength)

timerVal = tic;

disp('\r\n\r\nEntered process_video_vadl function\r\n\r\n');

%Do not proceed if there are no deer images for that particular cluster
try
	disp(strcat('Trying to read video ',inFileChop));

	VideoReader(inFileChop);

	disp('Finished reading video');
catch
	disp('No deer images here! :(');
	disp(strcat('No deer images for ',inFileChop));
	return
end	

disp('\r\n\r\nLoading files in proces video vadl function\r\n\r\n');

displog(['Loading ' inFileChop inFileCommon]);

%creating multiple videos, each with background images will eat a lot of disk space
%so we write to just one video each for L, S and O
L_file = gen_file_name(outFile,'_L'); S_file = gen_file_name(outFile,'_S');
%create cell arrays to store the videowriters - cannot get elements out of cell arrays :(
vL = VideoWriter(L_file,'Uncompressed AVI');
vS = VideoWriter(S_file,'Uncompressed AVI');
vO =  VideoWriter(outFile,'Uncompressed AVI');
open(vL); open(vS); open(vO);

clear load_video_file_vadl;%clears the fn, clearing the persistant (static) variable in it


while true %dangerous but we will break inside 

%video = load_video_file(inFile);
%clear video I A T M;

%clearvars -except stats timerVal method_id algorithm_id inFileChop inFileCommon outFile chopLength %clear everything but these

video = [];
[video_id, nChopFrames, video] = load_video_file_vadl(inFileChop, inFileCommon, chopLength, bgLength);


disp(['size of video = ' num2str(size(video))])
whos video

disp(['processing video v_id ' num2str(video_id) ', video #frames = ' num2str(video.nrFramesTotal)]);

disp(['nChopFrames is ' num2str(nChopFrames)]);

if nChopFrames == 0
    disp('Breaking out of process video loop');
    break
else
   % disp(['nChopFrames ' num2str(nChopFrames)]);
     disp('Not braking out of loop');
end


%%% Matrix-based methods
% i.e: process_video('RPCA', 'FPCP', 'dataset/demo.avi', 'output/demo_FPCP.avi');
if(strcmp(method_id,'RPCA') || strcmp(method_id,'ST') || strcmp(method_id,'MC') ...
|| strcmp(method_id,'LRR') || strcmp(method_id,'TTD') || strcmp(method_id,'NMF'))
  M = im2double(convert_video_to_2d(video));
  params.rows = video.height;
  params.cols = video.width;
	results = run_algorithm(method_id, algorithm_id, M, params);
  movobj = convert_2dresults2mov([],results.L,results.S,results.O,video);
end

%%% Tensor-based methods
% i.e: process_video('TD', 'HOSVD', 'dataset/demo.avi', 'output/demo_HOSVD.avi');
if(strcmp(method_id,'TD') || strcmp(method_id,'NTF'))
  A = im2double(convert_video_to_3d(video));
  T = tensor(A);
	results = run_algorithm(method_id, algorithm_id, T, []);
  movobj = convert_3dresults2mov([],results.L,results.S,results.O,size(T,3));
end

displog(['Saving results of video_id / part ' video_id]);
save_results_vadl(video_id, nChopFrames,movobj,vL,vS,vO,outFile);

displog('Process finished!');
displog(['CPU time: ' num2str(results.cputime)]);

stats.cputime = results.cputime; % Elapsed time for decomposition
stats.totaltime = toc(timerVal); % Total elapsed time

end

%close the video writers
close(vL); close(vS); close(vO);
clear L_file S_file;

disp('Exiting process_video_vadl function');
return
end
