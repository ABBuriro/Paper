function[Perf] = AlcoholTestLDA(Q,Vote)
% Q indicates wavelets per filterbank and the invaraince scale, like 810.5.
% subwise indicates whether the test be performed based on leave subject
% out 10-fold cross validation or on overall samples
% 20 subjects per group were chosen to balance the data and evenly
% dirstribute the number of sample per fold
% Subject inclusion/exclusion may slightly change the performances. The
% performances reported in the paper are based on the following subjects.
% by Abdul Baseer Buriro (email: abdul.baseer@iba-suk.edu.pk)
% date: May 2021
% ------------------------------------------------------------------------
rng('default')
Sub = {'co2a0000365';   'co2a0000368';  'co2a0000369'; ...
    'co2a0000372';      'co2a0000375';  'co2a0000377'; ...
    'co2a0000385';      'co2a0000392';  'co2a0000398'; ...
    'co2a0000400';      'co2a0000403';  'co2a0000404'; ...
    'co2a0000405';      'co2a0000406';  'co2a0000407'; ...
    'co2a0000409';      'co2a0000410';   'co2a0000414';...
    'co2a0000415';      'co2a0000416';...
    'co2c0000339';      'co2c0000340';  'co2c0000341'; ...
    'co2c0000342';      'co2c0000344';  'co2c0000345'; ...
    'co2c0000346';      'co2c0000347';  'co2c0000348'; ...
    'co2c0000351';      'co2c0000354';  'co2c0000356'; ...
    'co2c0000357';      'co2c0000363';  'co2c0000374'; ...
    'co2c0000383';      'co2c0000389';  'co2c0000393'; ...
    'co2c0000397';      'co2c1000367'};
%   'co2a0000411'; ...
%   'co2a0000412'; ...
%   'co2c0000337'; 'co2c0000338'; ...
%   total EEG records (40 subjects * 16 trails/subject)
[Feat,Lab] = Concatenate(Q,Sub); 
Feat = single(Feat); Lab = single(Lab);
K_test = 10;
cv_t = cvpartition(Lab,'k',K_test);
trails = 16;
win = length(Lab)/(trails*length(Sub));
Perf = cell(K_test,1);
for i = 1:K_test
    clc,close all
    disp(i);
    
    trainFeat = Feat(cv_t.training(i),:);
    trainLab = Lab(cv_t.training(i));
    testFeat = Feat(cv_t.test(i),:);
    testLab = Lab(cv_t.test(i));
   
    [trainFeat,testFeat] = AB_Standardize(trainFeat,testFeat);
    % -----------------------------------------------------
     FeatSel = AB_completeSF(trainFeat, trainLab, 'AUC');
    ldamod = fitcdiscr(trainFeat(:,FeatSel), trainLab,'prior',[0.5 0.5]);
    [Prlda,scorelda] = predict(ldamod,testFeat(:,FeatSel));
    name = '-10-fold-LDA-test.mat';
    if strcmpi(Vote,'Yes')
        [Prlda,scorelda] = SoftMajority(Prlda,scorelda,win);
        testLab = testLab(1:win:end);
        name = '-10-fold-NMJLDA-test.mat';
    end
    % ----------------
    P1 = AB_Performances(testLab, Prlda, scorelda);
    Perf{i} = P1;
end

save(strcat(num2str(Q),name), 'Perf');
end
% ---------

function[Pred1,score1] = SoftMajority(Pred,score,win)
L = length(Pred);
L = L - mod(L,win);
LL = L/win;
score1 = single(zeros(LL,2));
Pred1 = single(zeros(LL,1));
for i = 1:LL
    in  = (i-1)*win+1; fn = win*i;
    score1(i,:) = mean(score(in:fn,:)); 
    if ischar(Pred) == 1
        Pred1(i) = mode(Pred(in:fn));
    else
        Pred1(i) = round(mode(Pred(in:fn))); 
    end
end
end
