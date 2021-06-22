% Abdul Baseer Buriro
% abdul.baseer@iba-suk.edu.pk
% August 24, 2020
% The function is based on supervised feature selection approach
% and does selects the discrimonotry features.
% INPUT: training set features and corresponding labels
% OUTPUT: selected features
% ------------------------------------------------------------------------
function [FeatSel,idxv,idxR,val] = AB_completeSF(trainFeat, trainLab, option)
%%
% Preprocessing.
clc
% trainLab = single(trainLab);
trainFeat = single(trainFeat);
L = length(trainLab);
[r,~] = size(trainFeat);
if L ~= r
    trainFeat = trainFeat';
end
%%
% Fisher score-based ranking.
% Ref: Gu - Generalized Fisher Score for Feature Selection, 
% Uncertain. Artif. Intell. 2011 
U = unique(trainLab);                       % classes/labels
feat_mu = mean(trainFeat, 1);
feat_var = var(trainFeat, 0, 1);
idxv = isinf(feat_var);
feat_mu(:,idxv)=[];
feat_var(:,idxv)=[];
trainFeat(:,idxv)=[];
trdemean = 0;
for i = 1:length(U)                         
    Feat = trainFeat(trainLab == U(i), :);  % features per labels
    mFeat = mean(Feat,1);                   % feature means
    NoF = sum(trainLab == U(i));              % priors 
    trdemean = trdemean + NoF*(mFeat-feat_mu).^2;     % numerator of Fisher Score
end
fs = trdemean./feat_var;
[val,idxR] = sort(fs,'descend');              % idxR shows feature ranking
idxR(isnan(val)|isinf(val)) = [];
val(isnan(val)|isinf(val)) = [];
T = length(idxR);
C = zeros(T,1);
i = 1;
while (i < T) %&& (i < 501)
    for j = i+1:length(idxR)
        C(j) = corr(trainFeat(:,idxR(i)),trainFeat(:, idxR(j)));
    end
    idxR(C > 0.9) = [];
    i = i+1;
    T = length(idxR);
    C = zeros(T,1);
    display(strcat(num2str(i),'/',num2str(T)));  
end
idxR = idxR(1:i);
if strcmp(option, 'AUC')
    FeatSel = AB_CV(trainFeat, trainLab, idxR, 10, 70,70,0.99,1e-3);
else
    FeatSel = AB_CV_ACC(trainFeat,trainLab,idxR,10,70,70,0.999,1e-3);
end
end
%%
% wrapper-based sequential forward selection method. The classifier used in
% this code is LDA
function [selectedF] = ...
    AB_CV_ACC(Features, Labels, FR, fold, maxFeat, maxDel, maxACC, const)
% LDA based cross-validation followed by ranking to select features.
if nargin < 7
    maxACC = 0.999;
end
if nargin < 6                               % allowable number of features 
    maxDel = 100;
end
delt = 0;                                   % initialization of deletion counter
if nargin < 5
    maxFeat = 50;
end
if nargin < 4
    fold = 5;
end
if ~exist('const','var')
    const = 1e-3;  
end
cv = cvpartition(Labels, 'k', fold);
accX = zeros(fold,1);                       % Per fold cross validation ROC-AUC
accY = zeros(fold,1); 
X = Features(:, FR(1));
for k = 1 : fold                          
    trainX = X(cv.training(k), :);          % No of observations
    trlabelX = Labels(cv.training(k));
    ClassifierX = fitcdiscr(trainX, trlabelX,'discrimType','pseudoLinear');                 
    testX = X(cv.test(k), :);
    telabelX = Labels(cv.test(k));
    [Pr, ~] = predict(ClassifierX, testX);
    accX(k) = sum(Pr == telabelX)/length(telabelX);
    display(strcat(num2str(k), '-fold'));
end
ACCX = mean(accX); 
m = length(FR);   
acc = zeros(m,1);
acc(1) = ACCX;
i = 2; 
while (i < m) && (acc(i) < 0.8)                 
    Y = Features(:, FR(1:i));
    display(strcat(num2str(i),'/',num2str(m)));        
    for k = 1 : fold                                                
        trainY = Y(cv.training(k), :);    
        trlabelY = Labels(cv.training(k));
        ClassifierY = fitcdiscr(trainY,trlabelY,'discrimType','pseudoLinear');                 
        testY = Y(cv.test(k), :);
        telabelY = Labels(cv.test(k));
        [Pr, ~] = predict(ClassifierY,testY);
        accY(k)= sum(Pr == telabelY)/length(telabelY);
   end
ACCY = mean(accY);
    if ACCY > ACCX + ACCY*const
        ACCX = ACCY;
        acc(i) = ACCY;
        if acc(i) >= maxACC || i >= maxFeat % Stopping criterion
            FR(i+1:end) = [];
            m = length(FR);
        end
        i = i+1;                            % feature counter
        delt = 0;                           % restting deletion counter
    else
        acc(i) = ACCX;
        if acc(i) >= maxACC || i >= maxFeat || delt >= maxDel      
            FR(i+1:end) = [];
            m = length(FR); %#ok<NASGU>
        end
        FR(i) = [];                         % ranked feature deletion
        delt = delt + 1;                    % deletion counter
        m = length(FR);
    end
    clc,      
end     
selectedF = FR; 
end
%%