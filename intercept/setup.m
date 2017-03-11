% Airport Setup
ctower = struct('x',0,'y',-50,'val',10,'damage',0);
jet1 = struct('x',100,'y',50,'val',4,'damage',0);
jet2 = struct('x',100,'y',0,'val',3,'damage',0);
jet3 = struct('x',100,'y',-50,'val',3,'damage',0);
hangar = struct('x',0,'y',150,'val',2,'damage',0);
r = [ctower, jet1, jet2, jet3, hangar];

% Defenders
d1 = struct('x',[0],'y',[0],'R',5,'S',.8,'V',20,'a',0,'vdhat',[],'t_int',[],'t_reach',[],'ca',.1);
d2 = struct('x',[0],'y',[0],'R',5,'S',.8,'V',10,'a',0,'vdhat',[],'t_int',[],'t_reach',[],'ca',.1);
d3 = struct('x',[0],'y',[0],'R',5,'S',.8,'V',10,'a',0,'vdhat',[],'t_int',[],'t_reach',[],'ca',.1);
d = [d1,d2,d3];

% Attackers
a1 = struct('x',[],'y',[],'S',.7,'V',10,'t',[],'vahat',[],'active',1,'t_destroy',[]);
a2 = struct('x',[],'y',[],'S',1,'V',10,'t',[],'vahat',[],'active',1,'t_destroy',[]);
a3 = struct('x',[],'y',[],'S',.5,'V',10,'t',[],'vahat',[],'active',1,'t_destroy',[]);
a = [a1,a2,a3];

radar = 1000; % 1km radar detection
heading = [0, 360]; % Range of heading attackers come from
rng(0,'twister');
th = (heading(2)-heading(1)).*rand(length(a),1) + heading(1);
for i=1:length(a)
    a(i).x = radar*cosd(th(i));
    a(i).y = radar*sind(th(i));
end

save('config1','r','d','a');

% figure; hold on;
% for i=1:length(r)
%     plot(r(i).x,r(i).y,'bo');
% end
% for i=1:length(d)
%     plot(d(i).x,d(i).y,'ko');
% end
% for i=1:length(a)
%     plot(a(i).x,a(i).y,'ro');
% end
% xlim([-1000 1000]); ylim([-1000 1000]);