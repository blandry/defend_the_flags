close all;

% Load the starting configuration
config_name = 'config2.mat';
load(config_name)

% Attacker/target pairs
rng(1,'twister');
g = [1,2,3,4,5]'; %floor(rand(length(a),1)*length(r)+1);
G = zeros(length(r),length(a));
for i=1:length(a)
    a(i).t = g(i);
end

batch_size = 100;
damage = zeros(1,batch_size);
for i=1:batch_size
    % Load the starting configuration from setup.m
    load(config_name)
    for j=1:length(a)
        a(j).t = g(j);
    end
    [attackers,defenders,t,r,c] = simulator(a,d,r,5,'coord');
    damage(i) = sum([r.damage]);
end

mean(damage)
var(damage)

figure(1); hold on;
for z = 1:size(defenders{1},1)
    clf
    hold on
    
    for i=1:length(attackers)
        plot(attackers{i}(z,1),attackers{i}(z,2),'r+');
    end
    
    for i=1:length(defenders)
        plot(defenders{i}(z,1),defenders{i}(z,2),'k*');
    end

    for i=1:length(r)
        plot(r(i).x,r(i).y,'bo');
    end


    pause(0.01)
end


