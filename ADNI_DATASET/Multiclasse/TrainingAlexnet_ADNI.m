% MULTICLASS CLASSIFICATION - (normal control, mild cognitive impairment,
% alzheimer)
% CROSS-SECTIONAL
% STANDARD TRANSFER LEARNING - ALEXNET


%-----------------------  DATASET ACQUISITION --------------------------
classNumber = 3;
augSize = 227;
models_folder = "D:\Sara\TEST\Results\Multiclass\Alexnet"
model_name = "alexnet_adni_multiclass_200ep"

R = "D:\Sara\TEST\png";
S = dir(fullfile(R,'*.png'));
labels =[];
patientsData = 'Dati pazienti.csv'; % Data
T = readtable(patientsData); % Loads data into table
brainImgs = [];

for i = 1:numel(S)
    status = parseSubjectStatusADNI(fullfile(R,S(i).name),T); % Gets status of patient from the table
    brainImgs = [brainImgs fullfile(R,S(i).name)]; % Gets patient's MRI
    if status == "CN"
        labels = [labels "normal control"]; % healthy
    else
        if status == "MCI"
            labels = [labels "mild cognitive impairment"]; 
        else
            labels = [labels "alzheimer"]; 
        end
     end
end

%-------------------------- Creation of datastore ----------------------
brainLabels = categorical(labels);
brainDatastore = imageDatastore(brainImgs);
brainDatastore.Labels = brainLabels;

% Splitting into train set(80%), validation set (10%) and test set (10%)
[trainImgs,valSet,testImgs] = splitEachLabel(brainDatastore,0.8,0.1,0.1,'randomized');
testImgs.ReadFcn = @(filename)gray2rgb_resize(filename,augSize); % Resizing of test set
% Augmentation of train set and validation set
imageAugmenter = imageDataAugmenter("RandRotation",[-35 35],"RandXScale",[0.5 4],"RandYScale",[0.5 1]);
trainAug = augmentedImageDatastore([augSize augSize],trainImgs,"ColorPreprocessing","gray2rgb","DataAugmentation",imageAugmenter);
valAug = augmentedImageDatastore([augSize augSize],valSet,"ColorPreprocessing","gray2rgb","DataAugmentation",imageAugmenter);

% ------------------   Network initialization   --------------------------
net = alexnet;
layers = net.Layers;
layers(end - 2) = fullyConnectedLayer(classNumber); % Multiclass
layers(end) = classificationLayer();

% Vengono settate le training options
options = trainingOptions('adam',"Plots","training-progress","ValidationData",valAug,"InitialLearnRate",0.0001,"MaxEpochs",200,"ValidationFrequency",30);

% -------------------    Train Network    -------------------------------
trainedNet = trainNetwork(trainAug,layers,options);
save(fullfile(models_folder, model_name), "trainedNet");
preds = classify(trainedNet, testImgs);
accuracy = nnz(preds == testImgs.Labels)/numel(preds)

%Confusion Chart
chart = confusionchart(preds,testImgs.Labels)





