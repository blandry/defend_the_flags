clear all;

% number of attackers
A = 5;

% number of defenders
D = 3;

% cost of allocation
Ca = rand(1,D);

% number of resources
R = 2;

% cost of each resource
c = rand(1,R)*10+1;

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
best_M = zeros(D,A);

m = zeros(1,D);
for k=1:(A+1)^D
    
    % defender/attacker pairs (the control input)
    % zero means no assignment
    % exhaustively enumerate solutions
    for i=D:-1:1
        if m(i) < A
           m(i) = m(i) + 1;
           break;
        else
           m(i) = 0;  
        end
    end
    
    M = zeros(D,A);
    for i=1:D
        if m(i) > 0
           M(i,m(i)) = 1;        
        end
    end
    
    exp_cost(k) = c*(ones(R,1)-exp(G*log(ones(A,1)-exp(log(.9999*ones(D,A)-M.*P)'*ones(D,1))))) + (M*ones(A,1))'*Ca';
    
    if exp_cost(k) < min_exp_cost
        min_exp_cost = exp_cost(k);
        best_sol = m;
        best_M = M;
    end
    
    waitbar(k/(A+1)^D);
end

fprintf('Optimal solution:\n');
display(best_sol);

histogram(exp_cost);