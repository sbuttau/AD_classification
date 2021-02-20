% BINARY CLASSIFICATION - (NC vs MC&AD)
% CROSS-SECTIONAL
% STANDARD TRANSFER LEARNING -  INCEPTION RESNET V2

addpath('/home/server/MATLAB/topics/AD_classification/ADNI_DATASET/');


%-----------------------  DATASET ACQUISITION --------------------------
classNumber = 2;
augSize = 299;
root_folder = "/home/server/MATLAB/topics/AD_classification/ADNI_DATASET/Binaria/";
models_folder = fullfile(root_folder, 'models');
model_name = "inceptionresnetv2_adni_multiclass_200ep_mbs128";

R = "/home/server/MATLAB/dataset/ADNI/png/";
S = dir(fullfile(R,'*.png'));
labels =[];
patientsData = "/home/server/MATLAB/dataset/ADNI/DatiPazienti.csv"; % Data
T = readtable(patientsData); % Loads data into table
brainImgs = [];

for i = 1:numel(S)
    status = parseSubjectStatusADNI(fullfile(R,S(i).name),T); % Gets status of patient from the table
    brainImgs = [brainImgs fullfile(R,S(i).name)]; % Gets patient's MRI
    if status == "CN"
        labels = [labels "healthy"]; % healthy
    else
        labels = [labels "dementia"];
    end
end

%-------------------------- Creation of datastore ----------------------
brainLabels = categorical(labels);
brainDatastore = imageDatastore(brainImgs);
brainDatastore.Labels = brainLabels;

% Splitting into train set(80%), validation set (10%) and test set (10%)
[trainImgs,valImgs,testImgs] = splitEachLabel(brainDatastore,0.8,0.1,0.1,'randomized');
testImgs.ReadFcn = @(filename)gray2rgb_resize(filename,augSize); % Resizing of test set
% Augmentation of train set and validation set
imageAugmenter = imageDataAugmenter("RandRotation",[-45 35],"RandXScale",[0.5 4],"RandYScale",[0.5 9]);
trainAug = augmentedImageDatastore([augSize augSize],trainImgs,"ColorPreprocessing","gray2rgb","DataAugmentation",imageAugmenter);
valAug = augmentedImageDatastore([augSize augSize],valImgs,"ColorPreprocessing","gray2rgb","DataAugmentation",imageAugmenter);
trainSet = imageDatastore(cat(1,trainImgs.Files, trainAug.Files));
trainSet.Labels = cat(1,trainImgs.Labels,trainImgs.Labels);
trainSet.ReadFcn = @(filename)gray2rgb_resize(filename,augSize); % Resizing of train set

valSet = imageDatastore(cat(1,valImgs.Files,valAug.Files));
valSet.Labels = cat(1,valImgs.Labels, valImgs.Labels);
valSet.ReadFcn = @(filename)gray2rgb_resize(filename,augSize); % Resizing of validation set

% ------------------   Network initialization   --------------------------
net = inceptionresnetv2;
layers = layerGraph(net);
newFCLayer = fullyConnectedLayer(classNumber,'Name','new_fc');
layers = replaceLayer(layers,'predictions',newFCLayer);
newCLLayer = classificationLayer('Name','new_output');
layers = replaceLayer(layers,'ClassificationLayer_predictions',newCLLayer);

% Vengono settate le training options
options = trainingOptions('adam',"Plots","training-progress","ValidationData",valSet,"InitialLearnRate",0.0001,"MaxEpochs",200,"ValidationFrequency",30,"MiniBatchSize",10);

% -------------------    Train Network    -------------------------------
trainedNet = trainNetwork(trainSet,layers,options);
save(fullfile(models_folder, model_name), "trainedNet");
preds = classify(trainedNet, testImgs);
accuracy = nnz(preds == testImgs.Labels)/numel(preds)


%Confusion Chart
chart = confusionchart(preds,testImgs.Labels);
save(fullfile(models_folder, "inceptionresnetv2_chart"), "chart");
