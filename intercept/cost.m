function exp_cost = cost(c,Ca,D,A,R,m,G,P)

M = zeros(D,A);
for i=1:D
    if m(i) > 0
       M(i,m(i)) = 1;        
    end
end

exp_cost = c*(ones(R,1)-exp(G*log(ones(A,1)-exp(log(.9999*ones(D,A)-M.*P)'*ones(D,1))))) + (M*ones(A,1))'*Ca';

end

