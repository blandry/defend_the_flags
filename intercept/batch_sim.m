close all;
[a,d,r] = random_setup(10,10,5);
[att_m,def_m,t_m,r_m,~,d_m] = simulator(a,d,r,Inf,'market');
damage_m = sum([r_m.damage]);
[att_g,def_g,t_g,r_g,~,d_g] = simulator(a,d,r,Inf,'coord');
damage_g = sum([r_g.damage]);

max_damage = 0;
for j=1:numel(a)
    max_damage = max_damage + r(a(j).t).val;
end

%% Animation
animation('market',t_m,att_m,def_m,r_m,d_m,50)
animation('greedy',t_g,att_g,def_g,r_g,d_g,50)