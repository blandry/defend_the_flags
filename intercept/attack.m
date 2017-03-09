function [pij] = attack(di,aj,first)
% Compute the attack success probability given defender di and attacker aj
%   first is binary 1 if it is the first attack of the interaction (higher
%   prob), 0 if not first attack

Beta = 5;
discount_factor = .5;
pij = 1/(1+exp(-Beta*(di.S-aj.S)));

% For the first attack
if ~first
    pij = pij*discount_factor;
end
    
end

