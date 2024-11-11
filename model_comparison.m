function bic = model_comparison(tbl)

    % Compute Bayesian information criterion for all the models evaluated
    % in the paper.
    %
    % USAGE: bic = model_comparison([tbl])
    %
    % INPUTS:
    %   tbl (optional) - data table
    %
    % OUTPUTS:
    %   bic - vector of Bayesian information criterion values
    %
    % Sam Gershman, Nov 2024

    if nargin < 1
        tbl = readtable('Lak20_dopamine_data.csv');
    end

    model = fitlm(tbl,'outcomeresponse ~ outcome + action_value + cost');
    bic(1) = model.ModelCriterion.BIC;
    model = fitlm(tbl,'outcomeresponse ~ outcome + action_value + surprisal');
    bic(2) = model.ModelCriterion.BIC;
    model = fitlm(tbl,'outcomeresponse ~ outcome + cost');
    bic(3) = model.ModelCriterion.BIC;
    model = fitlm(tbl,'outcomeresponse ~ action_value + cost');
    bic(4) = model.ModelCriterion.BIC;
    model = fitlm(tbl,'outcomeresponse ~ outcome + action_value + surprisal + cost');
    bic(5) = model.ModelCriterion.BIC;
    tbl.stay = [0; tbl.action(1:end-1)==tbl.action(2:end)];
    tbl.last_outcome = [0; tbl.outcome(1:end-1)];
    model = fitlm(tbl,'outcomeresponse ~ outcome + action_value + stay + stay:last_outcome');
    bic(6) = model.ModelCriterion.BIC;