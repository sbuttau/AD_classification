% Classificazione livello di demenza (Dataset: kaggle, rete:
% InceptionResnetv2 allenata su dataset OASIS)
% Multiclasse: NonDemented, VeryMildDemented, MildDemented,
% ModerateDemented

%-----------------------  Gestione dataset --------------------------
% Vengono estratte le immagini dalla cartella "all image", e per ogni
% immagine si controlla il nome della stessa: la parte iniziale del nome
% rivela la classe di appartenenza di quella immagine. Ogni immagine viene
% salvata nell'array brainImgs e l'etichetta corrispondente nell'array
% brainLabels.
filepath1 = "Alzheimer_s Dataset\all image";
S = dir(fullfile(filepath1,"*.jpg"));
for i = 1: numel(S)
    brainImgs(i) = fullfile(filepath1,S(i).name);
    if(contains(S(i).name,"verymildDem"))
               brainLabels(i) = "mild dementia";
    else
        if(contains(S(i).name,"nonDem"))
           brainLabels(i) = "healthy";        
        else
            if(contains(S(i).name,"mildDem"))
        brainLabels(i) = "mild dementia";
            else
                if(contains(S(i).name,"moderateDem"))
                   brainLabels(i) = "moderate dementia";
                end
            end
        end
    end
end

% ------------------   Creazione del datastore   -----------------------
brainImgsDs = imageDatastore(brainImgs); % Datastore 
brainLabels = categorical(brainLabels);
brainImgsDs.Labels = brainLabels; % Etichette del datastore

brainImgsDs.ReadFcn = @(filename)gray2rgb_resize(filename,299);  %Vengono ridimensionate le immagini del test

preds = classify(trainedNet, brainImgsDs);
accuracy = nnz(preds == brainImgsDs.Labels)/numel(preds)

%Confusion Chart
chart = confusionchart(preds,brainImgsDs.Labels)

