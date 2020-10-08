function [value] = nii2png(path,file)


   % Read NIfTI Data and Header Info
   image = niftiread(fullfile(path,file));
   image_info = niftiinfo(fullfile(path,file));
   nifti_array = size(image);
   double = im2double(image);
   
   % If this is a 4D NIfTI
   if length(nifti_array) == 4
       
       % Create output folder
       cd(path)
       mkdir png
       
       % Get Vols and Slice
       total_volumes = nifti_array(4);
       total_slices = nifti_array(3);
       
       current_volume = 1;
       % Iterate Through Vol
       while current_volume <= total_volumes
           slice_counter = 0;
            % Iterate Through Slices
            current_slice = 1;
            while current_slice <= total_slices
                % Alternate Slices
                if currentslice == 89
                    data = mat2gray(double(:,:,current_slice,current_volume));
                   
                    % Set Filename as per slice and vol info
                    filename = file(1:end-4) + "_t" + sprintf('%03d', current_volume) + "_z" + sprintf('%03d', current_slice) + ".png";
                    
                    % Write Image
                    imwrite(data, char(filename));
                    current_slice = total_slices
                    current_volume = total_volumes
                    % If we reached the end of the slices
                    if current_slice == total_slices
                        % But not the end of the volumes
                        if current_volume < total_volumes
                            % Move to the next volume                            
                            current_volume = current_volume + 1;
                            % Write the image
                            imwrite(data, char(filename));
                        % Else if we reached the end of slice and volume
                        else         
                            % Write Image
                            imwrite(data, char(filename));
                            return
                        end
                    end
                 
                    % Move Images To Folder
                    movefile(char(filename),'png');
                    
                    % Increment Counters
                    slice_counter = slice_counter + 1;
              end
                current_slice = current_slice + 1;
            end
       current_volume = current_volume + 1;
       end
   % Else if this is a 3D NIfTI
   elseif length(nifti_array) == 3
       % Create output folder
       mkdir png
       
       % Get Vols and Slice
       total_slices = nifti_array(3);
       slice_counter = 0;
        % Iterate Through Slices
        current_slice = 1;
        while current_slice <= total_slices
            % Alternate Slices
            if current_slice == 89  
                data = mat2gray(double(:,:,current_slice));
               % Set Filename as per slice and vol info
                filename = file(1:end-4) + "_z" + sprintf('%03d', current_slice) + ".png";
                % Write Image
                imwrite(data, char(filename));
                % Move Images To Folder
                movefile(char(filename),'png');

                % Increment Counters
                slice_counter = slice_counter + 1;
            end
                if ((current_slice/total_slices)*100) == 100
                    value = 1;
                end
            
            current_slice  = current_slice  + 1;
        end
   elseif length(nifti_array) ~= 3 || 4
       value = 0;
   end
end


