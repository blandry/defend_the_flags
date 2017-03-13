clear all;

% number of attackers
A = 9;

% number of defenders
D = 5;

% cost of allocation
Ca = rand(1,D);

% number of resources
R = 9;

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

sorted_c = sort(c);

sols = [];
for j=0:A
    part_sol = [j;-1*ones(D-1,1)];
    sols = [sols,[lower_bound(c,Ca,D,A,R,part_sol,G,P,sorted_c);part_sol]];
end

% use a heuristic for an initial guess
best_sol = zeros(D,1);
i = 1;
for j=1:A
   if i >= D
       break;
   end
   target = find(G(:,j)==1);
   if c(target)*P(i,j) > Ca(i)
       best_sol(i) = j;
   end
   i = i+1;
end
best_sol = best_sol';
best_sol_cost = cost(c,Ca,D,A,R,best_sol,G,P);
num_sol_tested_bnb = 0;
exp_cost = [];

iter = 0;
max_iter = inf;

delta_converged = min(c);
num_deltas_converged = 2;
deltas = [];

sols_too_sparse = 0.0001;
num_best_update = 0;
min_best_update = 5;

tic;
while numel(sols)>0
   if iter > max_iter
       %display('reached max iterations');
       %break;
   else
       iter = iter+1;
   end
   density(iter) = num_best_update/iter;
   if num_best_update>=min_best_update && num_best_update/iter < sols_too_sparse
       %display('solutions are getting too sparse');
       %break;
   end
   %[best_lb,i] = min(sols(1,:));
   i = size(sols,2); % depth-first search
   %i = 1; % breadth-first search
   sol = sols(2:end,i);
   sols(:,i) = [];
   if numel(find(sol==-1))==0
       sol_cost = cost(c,Ca,D,A,R,sol,G,P);
       num_sol_tested_bnb = num_sol_tested_bnb + 1;
       exp_cost(num_sol_tested_bnb) = sol_cost;
       if sol_cost < best_sol_cost
           num_best_update = num_best_update + 1;
           best_sol = sol;
           deltas = [best_sol_cost-sol_cost,deltas];
           if numel(deltas)>=num_deltas_converged
               if max(deltas(1:num_deltas_converged))<delta_converged
                   %display('converged.');
                   %break;
               end
           end
           best_sol_cost = sol_cost;
       end
       continue;
   end
   unassigned = find(sol==-1);
   for j=0:A
     child = sol;
     child(unassigned(1)) = j; 
     child_cost_lb = lower_bound(c,Ca,D,A,R,child,G,P,sorted_c);
     %if child_cost_lb <= best_lb && child_cost_lb < best_sol_cost
     if child_cost_lb < best_sol_cost
        sols = [sols, [child_cost_lb; child]];
     end
   end
end
toc;

fprintf('Optimal solution:\n');
display(best_sol');
display(best_sol_cost);

hold on
histogram(exp_cost);
legend('solutions tested by exhaustive search','solutions tested by branch and bound');