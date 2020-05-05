%-----------------------  Gestione dataset --------------------------
%Estrazione del dataset di immagini e delle labels corrispondenti
k = 1;
n = 1;
u = 1;
v = 1;
filepath1 = "Dataset\disc" + num2str(n);
filepath2 = "\OAS1_000";
filepath3 = "_MR1\OAS1_000";
filepath4 = "_MR1.txt";
i = 1;

for z = 1 : numel(dir(fullfile("Dataset\","disc*"))) %Scorre i dischi
    for j = 1 :numel(dir(fullfile(filepath1,"OAS1_*"))) %Scorre le cartelle nei dischi
    
        if i > 9 
            filepath2 = "\OAS1_00";
            filepath3 = "_MR1\OAS1_00";
        end
        if i > 99
            filepath2 = "\OAS1_0";
            filepath3 = "_MR1\OAS1_0";
        end
        %Genero il path del file di testo
        filepath = filepath1 + filepath2 + num2str(i)+ filepath3 + num2str(i) + filepath4;
        R = filepath1 + filepath2 + num2str(i) + "_MR1\RAW"; %Path della cartella RAW
        S = dir(fullfile(R,'*.gif'));
        array = strings(1,numel(S)); %Inizializzo l'array
        CDR = parseSubjectStatus(filepath); %Ricavo il Clinical Dementia Rating (livello di demenza)
          if CDR == 0 %Se � nullo, il paziente � sano
              healthyIndx(u) = CDR; %Salvo l'indice
              %Salvo le immagini in un cell array   
              for k = 1: numel(S)
                 array(k) = fullfile(R,S(k).name);
              end
              healthyImgs{u} = array;
              u=u+1;
          end
        if CDR > 0 %Se � > 0, il paziente � affetto da demenza
            
            dementIndx(v) = CDR; % Salvo l'indice
            %Salvo le immagini in un cell array 
            for k = 1: numel(S)
                array(k) = fullfile(R,S(k).name);  
            end
            dementImgs{v} = array;
            v = v+1;
        end     
    i = i+1;
    end   
    n = n+1;
    filepath1 = "Dataset\disc" + num2str(n);
end

% Conversione del cell array dementImgs ad array di stringhe per la
% creazione del datastore e creazione delle etichette
dementStrings = [];
dementLabels = [];
for i = 1:size(dementImgs, 2)
    dementStrings = [dementStrings dementImgs{i}];
end
for i = 1:size(dementStrings,2)
    dementLabels = [dementLabels "dementia"];
end
dementLabels = categorical(dementLabels);
% Conversione del cell array healthyImgs ad array di stringhe per la
% creazione del datastore e creazione delle etichette
healthyStrings = [];
healthyLabels = [];
for i = 1:size(healthyImgs, 2)
    healthyStrings = [healthyStrings healthyImgs{i}];
end
for i = 1:size(healthyStrings,2)
    healthyLabels = [healthyLabels "healthy"];
end
healthyLabels = categorical(healthyLabels);

% ------------------   Creazione del datastore   -----------------------
healthyDs = imageDatastore(healthyStrings); %Datastore dei cervelli "sani"
healthyDs.Labels = healthyLabels; %Etichetta della classe "healthy"
dementDs = imageDatastore(dementStrings); %Datastore dei cervelli con demenza
dementDs.Labels = dementLabels; %Etichetta della classe "dementia"
ds = imageDatastore(cat(1,healthyDs.Files,dementDs.Files));
ds.Labels = cat(1,healthyDs.Labels,dementDs.Labels);
ds = shuffle(ds);
%ds = combine(healthyDs,dementDs); %Datastore combinato

% Divisione tra training set(80%),validation set (10%) e test set (10%)
[trainImgs,valSet,testImgs] = splitEachLabel(ds,0.8,0.1,0.1,'randomized');
testImgs.ReadFcn = @(filename)gray2rgb_resize(filename,224); %Vengono ridimensionate le immagini del test
% Viene applicata l'augmentation al training set per aumentare la diversit�
% all'interno del dataset
imageAugmenter = imageDataAugmenter("RandRotation",[-35 35],"RandXScale",[0.5 4],"RandYScale",[0.5 1]);
trainAug = augmentedImageDatastore([224 224],trainImgs,"ColorPreprocessing","gray2rgb","DataAugmentation",imageAugmenter);
valAug = augmentedImageDatastore([224 224],valSet,"ColorPreprocessing","gray2rgb","DataAugmentation",imageAugmenter);

% ------------------   Creazione della rete   --------------------------
net = vgg19;
layers = net.Layers;
% Modifico il terzultimo e l'ultimo strato della rete
layers(end - 2) = fullyConnectedLayer(2); % Classificazione binaria
layers(end) = classificationLayer();
% Vengono settate le training options
options = trainingOptions('adam',"Plots","training-progress","ValidationData",valAug,"MiniBatchSize",30,"InitialLearnRate",0.0001,"MaxEpochs",300,"ValidationFrequency",30);

% -------------------    Train Network    -------------------------------
trainedNet = trainNetwork(trainAug,layers,options);
preds = classify(trainedNet, testImgs);
accuracy = nnz(preds == testImgs.Labels)/numel(preds)

%Confusion Chart
confusionchart(preds,testImgs.Labels)
