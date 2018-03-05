function [V_K_new] = update_policy(MDP, V_K, policy)
% Update the value function from V_(k) to V_(k+1)
%   MDP: a pre-defined $GridMap$
%   V_K: the old value function
%   policy: the policy which will be evaluated
rows = MDP.GridSize(1); % get: the number of rows
columns = MDP.GridSize(2); % get: the number of coloums

for row = 1:rows % scan every state on the map
    if row==1 % check: the terminal state
        V_K_new(row, :) = 0; % the values of terminal states are 0 
        continue;
    else
        
        for column = 1:columns
            temp_sum = 0; % Temporary variables, store the sum
            action = policy(row, column); % get the action which will be taken
            [states, probs] = MDP.getTransitions([row, column], action);
            % get the all possible and corresponding probility
            num_possible_next_state = size(states, 1);
            for possible_next_state = 1:num_possible_next_state % for every possible next state
                next_state = states(possible_next_state, :);
                this_reward = MDP.getReward([row, column], next_state);
                temp_sum = temp_sum + probs(possible_next_state) * ...
                    (this_reward + V_K(next_state(1),next_state(2)));
            end
            V_K_new(row, column) = temp_sum; 
            % update the new value function of state [row, column]
        end      
    end  
end

end

