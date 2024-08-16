function tbl = extract_trial_data_Lak20(BehPhotoM)

    % Extract dopamine response aligned to different events
    % This uses data from https://figshare.com/articles/dataset/VTA_DA_Vis2AFC/24298336?file=42649654

    if nargin < 1
        load('VTA_DA_Vis2AFC')
    end

    Animals = [48 50 51 64 69];
    sampleRate = 1200;  % sampling rate
    StartTime = 3700;   % seconds before event
    epoch = round(StartTime + 0.3*sampleRate):round(StartTime + 0.8*sampleRate);

    normEpoch = round(StartTime - 0.1*sampleRate):round(StartTime + 0.1*sampleRate);  %added by Armin 

    data = [];
    session_count = 0;

    for i = 1:length(Animals)
        for j = 1:length(BehPhotoM(Animals(i)).Session)
            session_count = session_count + 1;
            nTrials = size(BehPhotoM(Animals(i)).Session(j).TrialTimingData,1);     % number of trials in session
            correct = BehPhotoM(Animals(i)).Session(j).TrialTimingData(:,4);        % correct/incorrect
            action = BehPhotoM(Animals(i)).Session(j).TrialTimingData(:,3);         % which action (-1=L, 1=R)
            stimulus = BehPhotoM(Animals(i)).Session(j).TrialTimingData(:,2);       % stimulus (contrast)
            reward = correct*1.2;
            if BehPhotoM(Animals(i)).Session(j).TrialTimingData(1,8) == 1           % large reward on left side
                reward(action==-1) = reward(action==-1)*2;                          % reward magnitude
            else
                reward(action==1) = reward(action==1)*2;
            end
            if isfield(BehPhotoM(Animals(i)).Session(j),'NeuronBeepL')
                stimresponse = mean(BehPhotoM(Animals(i)).Session(j).NeuronStimL(:,epoch),2) - mean(BehPhotoM(Animals(i)).Session(j).NeuronStimL(:,normEpoch),2);
                actionresponse = mean(BehPhotoM(Animals(i)).Session(j).NeuronActionL(:,epoch),2) - mean(BehPhotoM(Animals(i)).Session(j).NeuronActionL(:,normEpoch),2);
                outcomeresponse = mean(BehPhotoM(Animals(i)).Session(j).NeuronRewardL(:,epoch),2) - mean(BehPhotoM(Animals(i)).Session(j).NeuronRewardL(:,normEpoch),2);

            else
                stimresponse = mean(BehPhotoM(Animals(i)).Session(j).NeuronStimR(:,epoch),2) - mean(BehPhotoM(Animals(i)).Session(j).NeuronStimR(:,normEpoch),2);
                actionresponse = mean(BehPhotoM(Animals(i)).Session(j).NeuronActionR(:,epoch),2) - mean(BehPhotoM(Animals(i)).Session(j).NeuronActionR(:,normEpoch),2);
                outcomeresponse = mean(BehPhotoM(Animals(i)).Session(j).NeuronRewardR(:,epoch),2) - mean(BehPhotoM(Animals(i)).Session(j).NeuronRewardR(:,normEpoch),2);

            end

            stimresponse = zscore(stimresponse);
            actionresponse = zscore(actionresponse);
            outcomeresponse = zscore(outcomeresponse);

            [cost, marginal] = compute_cost(stimulus,action);
            [state_value, action_value, action_diff] = compute_value(stimulus,reward,action);

            data = [data; zeros(nTrials,1)+i zeros(nTrials,1)+session_count (1:nTrials)' action stimulus reward stimresponse ...
                actionresponse outcomeresponse cost state_value action_value action_diff marginal];
        end
    end

    % create table
    varnames = {'animal' 'session' 'trial' 'action' 'stimulus' 'outcome' 'stimresponse' 'actionresponse' 'outcomeresponse' 'cost' 'state_value' 'action_value' 'action_diff' 'marginal'};
    tbl = array2table(data,'VariableNames',varnames);

    % write table to csv file
    writetable(tbl,'Lak20_dopamine_data.csv');