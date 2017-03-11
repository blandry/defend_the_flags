function P = compute_probs(IM,a,d)

td = 5;

A = numel(a);
D = numel(d);
P = zeros(D,A);

for i=1:D
    for j=1:A
        if IM(i,j).flag == 0 % There is no intercept path
            P(i,j) = 0;
        else
            p_first = attack(d(i),a(j),1);
            p_rest = attack(d(i),a(j),0);
            P(i,j) = 1-(1-p_first)*(1-p_rest)^(floor(IM(i,j).t_rem/td));
        end
    end
end

end

