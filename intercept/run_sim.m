clear; clc; close all;

% % Load the starting configuration from setup.m
% load('config1.mat')
% 
% % Attacker/target pairs
% %rng(5,'twister');
% g = floor(rand(length(a),1)*length(r)+1);
% G = zeros(length(r),length(a));
% for i=1:length(a)
%     a(i).t = g(i);
% end

[a,d,r] = random_setup(3,3,2);
[attackers,defenders,t,r,c,d] = simulator(a,d,r,Inf,'coord');

total_damage = sum([r.damage]);

%figure(2);
%plot(t,c);
%%
% figure(1); hold on;
% for z = 1:size(defenders{1},1)
%     clf
%     hold on
%     
%     for i=1:length(attackers)
%         plot(attackers{i}(z,1),attackers{i}(z,2),'r+');
%     end
%     
%     for i=1:length(defenders)
%         plot(defenders{i}(z,1),defenders{i}(z,2),'k*');
%     end
% 
%     for i=1:length(r)
%         plot(r(i).x,r(i).y,'bo');
%     end
% 
% 
%     pause(0.01)
% end
animation('hey',t,attackers,defenders,r,d,30)

