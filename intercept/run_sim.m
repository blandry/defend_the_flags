clear; clc; close all;

% Load the starting configuration from setup.m
load('config1.mat')

% Attacker/target pairs
rng(1,'twister');
g = floor(rand(length(a),1)*length(r)+1);
G = zeros(length(r),length(a));
for i=1:length(a)
    a(i).t = g(i);
end

[attackers,defenders] = simulator(a,d,r);

figure(1); hold on;
for i=1:length(defenders)
    plot(defenders{i}(:,1),defenders{i}(:,2),'k');
end
for i=1:length(r)
    plot(r(i).x,r(i).y,'bo');
end
for i=1:length(attackers)
    plot(attackers{i}(:,1),attackers{i}(:,2),'r');
end


