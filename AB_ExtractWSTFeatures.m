
% be in the folder
Q1 = 2;
Q2 = 1;
inv = [0.25 0.5 1];
Fs = 256;
trail = 16;
S = Fs*trail; 
for j = 1:length(inv)
    dir_sav = strcat("C:\Users\HP\Documents\MATLAB\Features",...
    num2str(Q1),num2str(Q2),num2str(inv(j)));
    if exist(dir_sav, 'dir') == 0
            mkdir(dir_sav);
            %dest_dir = [pwd dir_sav];
    end
    folder = "C:\Users\Dr Baseer\Documents\eeg_full\Subjectwise_data\";
    FileList = dir(fullfile(folder, '*.mat'));
    L = length(FileList);
    for i = 1:L
        %file = strcat('Data',num2str(i),'.mat');
        %data = importdata(strcat(folder,file));
        subject = FileList(i).name;
        data = importdata(strcat(folder,subject));
        sf = waveletScattering('SignalLength',S,...
            'InvarianceScale',inv(j),'SamplingFrequency',Fs,...
            'QualityFactor',[Q1 Q2]);
        X = data(:,1:16);                              % taking only channels
        if ~any(isnan(X))
            Feat = featureMatrix(sf,X(1:S,:));   % featureMatrix(sf,dat);
            % the dimension of x is coef X time window X number of channels (e.g.,
            % 104 X 4 X 16). Therefore, reshape to resolve the issue.
            T = size(Feat,2);
            Feat = permute(Feat,[2 1 3]);                 % windows X coef/paths X chan
            Feat = single(reshape(Feat, [], size(Feat,2)*size(Feat,3)));
            Lab = single(repmat(unique(data(1:S,17)),T,1));
            %Y = repmat(cell2mat(data_info.label(i)),T,1);
                    % Labels
            clc,
            disp(i);
           save(strcat(dir_sav,'\',subject(1:11),'.mat'),'Feat','Lab');
        end
    end
end
