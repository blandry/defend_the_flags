function [d] = allocate_bnb(P,a,d,r)

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

for i = 1:D
    d(i).a = best_sol(i);
end

end