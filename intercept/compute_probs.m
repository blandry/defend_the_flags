function P = compute_probs(IM,a,d)

Beta = 5;
discount_factor = .1;
td = 5;

A = numel(a);
D = numel(d);
P = zeros(D,A);

for i=1:D
    for j=1:A
        pij = 1/(1+exp(-Beta*(d(i).S-a(j).S)));
        P(i,j) = 1-(1-pij)*(1-discount_factor*pij)^(IM(i,j).t_rem/td);
    end
end

end

