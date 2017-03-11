function d = allocate_coord_descent(IM,P,a,d,r)

% number of active attackers (max 9)
A = size(P,2);

% number of defenders (max 9)
D = size(P,1);

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

M = zeros(D,A);
for i=1:D
    if d(i).a > 0 & d(i).a <= A
        M(i,d(i).a) = 1;
    end
end

% Does one loop through the defenders, choosing an allocation for each. 
for i=1:D
    best_cost = Inf;
    best_j = -1;
    for j = 1:A
        % evaluate cost of assigning defender i to assignment j
        Mp = M;
        Mp(i,:) = zeros(1,A);
        if j > 0
            Mp(i,j) = 1;
        end

        cost = c*(ones(R,1)-exp(G*log(ones(A,1)-exp(log(.9999*ones(D,A)-Mp.*P)'*ones(D,1))))) + (Mp*ones(A,1))'*Ca';
        if cost < best_cost
            best_cost = cost;
            best_j = j;
        end
    end
    
    % with prob 0.8, choose the best allocation, else choose randomly
    if rand < 0.2
        best_j = randi([1,A]);
    end
    
    alloc = zeros(1,A);
    if best_j > 0
        alloc(best_j) = 1;
    end
    
    M(i,:) = alloc;
end

[dnum,anum] = find(M==1);
for i=1:numel(dnum)
    d(i).a = anum(i);
end

fprintf('Current solution:\n');
display(M);

end