function animation(fname,t,attackers,defenders,r,d,points)
%Creates a plot animation and movie with name fname "filename"
% points is the number of time points to sample

% Create x and y position arrays for plotting
xatt = zeros(length(t),length(attackers));
yatt = zeros(length(t),length(attackers));
xdef = zeros(length(t),length(defenders));
ydef = zeros(length(t),length(defenders));
for i=1:length(t)
    for j=1:length(attackers)
        xatt(i,j) = attackers{j}(i,1);
        yatt(i,j) = attackers{j}(i,2);
    end
    for k=1:length(defenders)
        xdef(i,k) = defenders{k}(i,1);
        ydef(i,k) = defenders{k}(i,2);
    end
end

% Sample so you don't have as many points
sample = floor(linspace(1,length(t),points));
sample = [sample, length(t)];
xatt = xatt(sample,:);
yatt = yatt(sample,:);
xdef = xdef(sample,:);
ydef = ydef(sample,:);
t = t(sample);
d = d(sample);

% Compute max range
xmax = max([max(xdef),max(xatt)]);
xmin = min([min(xdef),min(xatt)]);
ymax = max([max(ydef),max(yatt)]);
ymin = min([min(ydef),min(yatt)]);

% Animation
figure('visible','on');
plot([r.x],[r.y],'ks','markersize',5);
hold on;
handle1 = plot(xatt(1,:), yatt(1,:),'rx', 'MarkerSize', 8, 'LineWidth', 2);
handle2 = plot(xdef(1,:), ydef(1,:),'bo', 'MarkerSize', 8, 'LineWidth', 2);
axis equal
axis([xmin xmax ymin ymax]);
str = sprintf('Damage = %d',d(1));
handle3 = text(xmin + .015*abs(xmin-xmax),ymax - .03*abs(ymax-ymin),str);

v = VideoWriter(fname);
% Desired movie length
td = 10; %s
v.FrameRate = ceil(length(t)/td);
v.Quality = 100;
open(v);
for id = 1:length(t)
    disp(100*id/length(t))
   % Update XData and YData
   set(handle1, 'XData', xatt(id,:)  , 'YData', yatt(id,:));
   set(handle2, 'XData', xdef(id,:)  , 'YData', ydef(id,:));
   set(handle3, 'String', sprintf('Damage = %d',d(id)));
   drawnow;
   frame = getframe(gcf);
   im = frame2im(frame);
   [imind,cm] = rgb2ind(im,256);
   if id == 1
       imwrite(imind,cm,fname,'gif', 'Loopcount',inf);
   else
       imwrite(imind,cm,fname,'gif','WriteMode','append');
   end
   writeVideo(v,frame);
end
close(v);

end

