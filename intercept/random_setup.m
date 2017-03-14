function [a,d,r] = random_setup(A,D,R)
% Randomly generates the system given number of attackers defenders
% resources A, D, R

% Setup attacker initial positions
a = repmat(struct('x',[],'y',[],'S',0,'V',0,'t',[],'vahat',[],'active',1,'t_destroy',[]), 1, A);
radar = 1000; % 1km radar detection
heading = [0, 360]; % Range of heading attackers come from
th_a = (heading(2)-heading(1)).*rand(A,1) + heading(1);
strengths = rand(1,A);
velocities = 10*rand(1,A)+5;
for j=1:A
    a(j).x = radar*cosd(th_a(j));
    a(j).y = radar*sind(th_a(j));
    a(j).S = strengths(j);
    a(j).V = velocities(j);
end

% Setup defender random attributes
d = repmat(struct('x',[0],'y',[0],'R',5,'S',0,'V',0,'a',0,'vdhat',[],'t_int',[],'t_reach',[],'ca',0), 1, D);
strengths = rand(1,D);
velocities = 10*rand(1,D)+5;
for i=1:D
    d(i).S = strengths(i);
    d(i).V = velocities(i);
end

% Resource values
r = repmat(struct('x',0,'y',0,'val',0,'damage',0), 1, R);
perimeter = 100; % All resources within perimeter radius
th_resource = (360).*rand(R,1) + heading(1);
r_resource = perimeter*rand(1,R);
values = floor(10*rand(1,R)+1);
for k=1:R
    r(k).x = r_resource(k)*cosd(th_resource(k));
    r(k).y = r_resource(k)*sind(th_resource(k));
    r(k).val = values(k);
end

% Randomly set attacker target pairs
g = floor(rand(length(a),1)*length(r)+1);
G = zeros(length(r),length(a));
for i=1:length(a)
    a(i).t = g(i);
end

end

