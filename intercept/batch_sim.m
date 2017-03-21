close all;
%% Problem setup
N = 100;
A = 7;
D = 7;
R = 5;

reallocate = 0; % 1 for reallocate on events, 0 for no reallocation
damage = 'Total';
cfunc = 'Total';

market_damage = zeros(1,N);
greedy_damage = zeros(1,N);
bnb_damage = zeros(1,N);
possible_damage = zeros(1,N);


%% Run the simulations
if reallocate
    allocate = Inf;
else
    allocate = 0;
end

for idx=1:N
    [a,d,r] = random_setup(A,D,R);
    [att_m,def_m,t_m,r_m,~,d_m] = simulator(a,d,r,allocate,'market',damage,cfunc);
    damage_m = sum([r_m.damage]);
    [att_g,def_g,t_g,r_g,~,d_g] = simulator(a,d,r,allocate,'coord',damage,cfunc);
    damage_g = sum([r_g.damage]);
    [att_b,def_b,t_b,r_b,~,d_b] = simulator(a,d,r,allocate,'bnb',damage,cfunc);
    damage_b = sum([r_b.damage]);

    % Compute total damage
    max_damage = 0;
    if strcmp(damage,'Total')
        max_damage = sum([r.val]);
    elseif strcmp(damage,'Incremental')
        for j=1:A
            max_damage = max_damage + r(a(j).t).val;
        end
    end
        
    market_damage(idx) = damage_m/max_damage;
    greedy_damage(idx) = damage_g/max_damage;
    bnb_damage(idx) = damage_b/max_damage;
    possible_damage(idx) = max_damage;
    disp(idx/N)
end

%% Plotting Results
hist([100*bnb_damage', 100*market_damage', 100*greedy_damage'],10);
%hist([100*market_damage', 100*greedy_damage'],10);
legstr1 = sprintf('Branch/Bound, \\mu=%.2f',mean(100*bnb_damage));
legstr2 = sprintf('Market, \\mu=%.2f',mean(100*market_damage));
legstr3 = sprintf('Greedy, \\mu=%.2f',mean(100*greedy_damage));
legend(legstr1,legstr2,legstr3);
%legend(legstr2,legstr3);
xlabel('Percent Max Damage (%)');
ylabel('Simulation Outcome Frequency');
if strcmp(damage,cfunc)
    match = 'Match';
else
    match = 'Mismatch';
end

if reallocate
    titlestr = sprintf(['A=%d, D=%d, R=%d, %s Resource Loss, Reallocate on Events  ' ...
        '\n Cost Function %s, %d Runs'],A,D,R,damage,match,N);
else
    titlestr = sprintf(['A=%d, D=%d, R=%d, %s Resource Loss, No Reallocation  ' ...
        '\n Cost Function %s, %d Runs'],A,D,R,damage,match,N);
end
title(titlestr,'fontsize',10);

%% Animation
%animation('market',t_m,att_m,def_m,r_m,d_m,50)
%animation('greedy',t_g,att_g,def_g,r_g,d_g,50)