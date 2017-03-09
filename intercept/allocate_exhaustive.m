function d = allocate_exhaustive(IM,P,a,d,r)

% number of attackers (max 9)
A = numel(a);

% number of defenders (max 9)
D = numel(d);

% cost of allocation
for i=1:numel(d)
   Ca(i) = d(i).ca; 
end

% number of resources
R = numel(r);

% cost of each resource
for i=1:numel(r)
   c(i) = r(i).val; 
end

% attacker/target pairs
G = zeros(R,A);
for j=1:A
    G(a(j).t,j) = 1;
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

[dnum,anum] = find(best_M==1);
for i=1:numel(dnum)
    d(i).a = anum(i);
end

end