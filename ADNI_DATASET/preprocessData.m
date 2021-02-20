% Renames files .nii from ADNI dataset in subfolder:
% "ADNI_foldername_imagenumber.nii", and converts volumetric files in png
% files in the proper 'png' folder.

D = struct2table(dir('./**/*.nii'));
D = D(~D.isdir,:);
for kk = 1:height(D)
  [~,folderName] = fileparts(D.folder{1});
  splittedName =strsplit(D.name{kk}, '_')
  firstPartName = [splittedName{2} '_' splittedName{3} '_' splittedName{4} '_']
  lastPartName = splittedName{end}
  newFileName = ['ADNI','_',firstPartName,lastPartName]
  movefile(fullfile(D.folder{kk},D.name{kk}),fullfile(D.folder{kk},newFileName));
  % For each volumetric file, the nii2png function is applied, which adds 
  % to the png folder the cross-sectional MRI of each patient.
  value = nii2png(D.folder{kk},D.name{kk});
  if value == 0
      disp('Error')
  end
end
