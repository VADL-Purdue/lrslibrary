%%% void save_results(struct,string)
%now with video id or part name
%
function save_results_vadl(video_id, nChopFrames, movobj, vL, vS, vO, outFile)
    
  %nChopFrames have number of deer frames in each video
  %vL, vS, vO - video writers containt the L,S and O videowriter objects

  if(strcmp(get_file_extension(outFile),'mat')) %Manu - we will not be using this part
    disp('Saving in mat file');
    save(outFile,'movobj');
  else  
    disp('Saving results in movie file');

    if(~isempty(movobj.L))
      %L_file = gen_file_name(outFile,strcat('dFrames-',num2str(nChopFrames),'_vid-',num2str(video_id),'_L')); %old technique

      disp('Saving low rank results');
      %v = VideoWriter(L_file,'Uncompressed AVI');
      %open(v);

      writeVideo(vL,movobj.L(1:nChopFrames)); %write only deer images

      %close(v);
      %movie2avi(movobj.L, L_file, 'compression', 'None');
      %clear L_file;
    end

    if(~isempty(movobj.S))

      %S_file = gen_file_name(outFile,strcat('dFrames-',num2str(nChopFrames),'_vid-',num2str(video_id),'_S'));
      disp('Saving sparse results');
      %v = VideoWriter(S_file,'Uncompressed AVI');
      %open(v);
      %writeVideo(v,movobj.S);

      writeVideo(vS,movobj.S(1:nChopFrames)); %write only deer images

      %close(v);
      %movie2avi(movobj.S, S_file, 'compression', 'None');
      %clear S_file;
    end

    if(~isempty(movobj.O))
      
      %by Manu
      %new outfile name - includes the video_id
      %outFileNew = gen_file_name(outFile,strcat('dFrames-',num2str(nChopFrames),'_vid-',num2str(video_id)));
        
      disp('Saving foreground result');
      %v = VideoWriter(outFileNew,'Uncompressed AVI');
      %open(v);
      %writeVideo(v,movobj.O);

      writeVideo(vO,movobj.O(1:nChopFrames)); %write only deer images

      %close(v);
      %movie2avi(movobj.O, outFile, 'compression', 'None');
    end
  end
end
