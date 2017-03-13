function bound = lower_bound(c,Ca,D,A,R,part_sol,G,P,sorted_c)

% % % number of attackers that could be left alone in the best case
% n = max(0, A - (D - numel(find(part_sol==0))));
% 
% % assume the attackers left alone reach lowest cost targets
% bound = sum(sorted_c(1:min(R,n)));
% 
% % and the cost of the current assignment
% for i=1:D
%    if part_sol(i)>0
%       bound = bound + Ca(i);
%    end
% end

% the best case scenario for each resource
bound = 0;
for i=1:R
   p = 1.0; % chances of survival (every attacker for that resource fails)
   for j=1:A
       if G(i,j) == 1
          % this attacker has to fail
          pa = 1.0; % probability of that attacker succeeding
          for k=1:D
             if part_sol(k)==j || part_sol(k)==-1 % note that we leave the possibility of defending it with remaining defenders
                pa = pa * (1-P(k,j));
             end
             if part_sol(k)==j
                bound = bound + Ca(k); % adding up the guaranteed cost of defending that resource
             end
          end
          p = p * (1 - pa); 
       end
   end
   bound = bound + c(i)*(1-p);
end

end

