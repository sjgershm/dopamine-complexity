function [state_value, action_value, action_diff] = compute_value(stimulus,reward,action)

    % Compute state and action values

    S = unique(stimulus);
    A = unique(action);

    state_value = zeros(size(stimulus));
    action_value = zeros(size(stimulus));
    action_diff = zeros(size(stimulus));

    for s = 1:length(S)
        ix = stimulus==S(s);
        if any(ix)
            state_value(ix) = mean(reward(ix));
            for a = 1:length(A)
                ix2 = ix & action==A(a);
                if any(ix2)
                    action_value(ix2) = mean(reward(ix2));
                end
            end

            if nargout > 2
                action_diff(ix) = max(0,mean(reward(ix&action==A(2)))) - max(0,mean(reward(ix&action==A(1))));
            end
        end
    end