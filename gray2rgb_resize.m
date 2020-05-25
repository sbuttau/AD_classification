%Converte un'immagine binaria in immagine rgb

function Irgb = gray2rgb_resize(filename,scale)
% Read the Image
I = imread(filename);
   if ismatrix(I)
     Irgb = cat(3, I, I, I);
     Irgb = imresize(Irgb,[scale scale]);
   end
end

