function [IM_active, a_active, map] = parse_active_attackers(IM, a)
% Takes the information variables that are used for allocations and removes
% the attackers that are not active that we don't want to assign stuff to

A_active = sum([a.active]);
IM_active = [];
a_active = [];

% Also create an array that maps the number of attackers, so if 4 attackers
% and a3 was inactive map would be [1 2 4] so that after the allocation we
% can convert back to proper index
map = zeros(1, A_active);

idx = 1;
% Remove the columns with inactive attackers
for j=1:numel(a)
    if a(j).active == 1
        IM_active = [IM_active, IM(:,j)];
        a_active = [a_active, a(j)];
        map(idx) = j;
        idx = idx + 1;
    end
end

end

