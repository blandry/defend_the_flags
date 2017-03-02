clear all;

% number of attackers (max 9)
A = 4;

% number of defenders (max 9)
D = 6;

% number of resources
R = 2;

% cost of each resource
c = rand(R,1)*10+1;

% intercept success probability
P = rand(D,A);

% attacker/target pairs
g = floor(rand(A,1)*R+1);
G = zeros(R,A);
for i=1:A
    G(g(i),i) = 1;
end

min_exp_cost = inf;
best_sol = 0;

for k=1:(A+1)^D

    % defender/attacker pairs (the control input)
    % zero means no assignment
    % exhaustively enumerate solutions
    m = dec2base(k-1,A,D);
    
    M = zeros(D,A);
    for i=1:D
        if floor(str2double(m(i)))>0
            M(i,floor(str2double(m(i)))) = 1;
        end
    end

    exp_cost(k) = c'*(ones(R,1)-exp(G*log(ones(A,1)-exp(log(.9999*ones(D,A)-M.*P)'*ones(D,1)))));
    
    if exp_cost(k) < min_exp_cost
        min_exp_cost = exp_cost(k);
        best_sol = m;
    end
    
    waitbar(k/(A+1)^D);
end

display(sprintf('Optimal solution: %s',best_sol));
hist(exp_cost);