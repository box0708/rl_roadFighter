function [V_K_new] = policy_evaluation(MDP, V_K, policy)
% Implement the iterative policy evaluation algorithm.
%   MDP: a pre-defined $GridMap$
%   V_K: the old value function (or the initiized value function of policy)
%   policy: the policy which will be evaluated
%
%   [RETURN] V_K_new: the value function.

last = zeros(size(V_K));
V_K_new = update_policy(MDP, V_K, policy);

for i = 1:100 % the max time of iterative
    if max(max(abs(V_K_new - last))) < 0.05 % the condition of end iterative
        break;
    else
        last = V_K_new;
        V_K_new = update_policy(MDP, V_K_new, policy);
    end
end

end

