close all;
N = 100;
market_damage = zeros(1,N);
greedy_damage = zeros(1,N);
possible_damage = zeros(1,N);
A = 8;
D = 5;
R = 4;
for idx=1:N
    [a,d,r] = random_setup(8,5,4);
    [att_m,def_m,t_m,r_m,~,d_m] = simulator(a,d,r,Inf,'market');
    damage_m = sum([r_m.damage]);
    [att_g,def_g,t_g,r_g,~,d_g] = simulator(a,d,r,Inf,'coord');
    damage_g = sum([r_g.damage]);
    max_damage = 0;
    for j=1:numel(a)
        max_damage = max_damage + r(a(j).t).val;
    end
    market_damage(idx) = damage_m/max_damage;
    greedy_damage(idx) = damage_g/max_damage;
    possible_damage(idx) = max_damage;
    disp(idx/N)
end

% Plotting Results
hist([100*market_damage', 100*greedy_damage'],10);
legstr1 = sprintf('Market, \\mu=%.2f',mean(100*market_damage));
legstr2 = sprintf('Greedy, \\mu=%.2f',mean(100*greedy_damage));
legend(legstr1,legstr2);
xlabel('Percent Total Damage');
ylabel('Number of Instances');
titlestr = sprintf('A=%d, D=%d, R=%d, Greedy Uses Total Damage Cost Function, %d Runs',A,D,R,N);
title(titlestr,'fontsize',8);

%% Animation
%animation('market',t_m,att_m,def_m,r_m,d_m,50)
%animation('greedy',t_g,att_g,def_g,r_g,d_g,50)