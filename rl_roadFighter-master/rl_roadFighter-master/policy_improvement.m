function [new_policy] = policy_improvement(policy, value_function)
% Implement the policy improvement step, using greedy algorithm.
%   policy: the old policy which will be improved.
%   value_function: a value function

rows = size(policy, 1); % get: the number of rows
columns = size(policy, 2); % get: the number of coloums

new_policy = policy;

for row = rows:-1:1
    for column = 1:columns % Scan every state in the whole space
       if row == 1
           new_policy(row, column) = policy(row, column); % The terminal state
       else
          if column == 1 % The leftmost states.
              temp = zeros(1, 2);
              temp(1) = value_function(row-1, column);
              temp(2) = value_function(row-1, column+1);
              [~, new_action] = max(temp); % Find the new action using greedy policy
              new_action = new_action + 1;
              %disp(new_action)
              if new_action ~= policy(row, column)
                  new_policy(row, column) = new_action; 
                  return;
              end
              %disp('pass')
          elseif column == columns % The rightmost states.
              temp = zeros(1, 2);
              temp(1) = value_function(row-1, column-1);
              temp(2) = value_function(row-1, column);
              [~, new_action] = max(temp); % Find the new action using greedy policy
              %disp(new_action)
              if new_action ~= policy(row, column)
                  new_policy(row, column) = new_action; % Update the new action
                  return; % End the policy improvement
              end       
              %disp('pass')
          else
              temp = zeros(1, 3);
              temp(1) = value_function(row-1, column-1);
              temp(2) = value_function(row-1, column);
              temp(3) = value_function(row-1, column+1);
              [~, new_action] = max(temp); % Find the new action using greedy policy
              %disp(new_action)
              if new_action ~= policy(row, column)
                  new_policy(row, column) = new_action; 
                  return;
              end
              %disp('pass')
          end
       end
       %disp('#####')
    end
end


end

