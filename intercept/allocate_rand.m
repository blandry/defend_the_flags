function d = allocate_rand(P,a,d,r)

% number of attackers (max 9)
A = numel(a);

% number of defenders (max 9)
D = numel(d);

for i=1:D;
    d(i).a = randi([0,A]);
end

end