clear;
xd = [0, 0];
xa = [1, 1];
xr = [2, .5];
Va = 1;
Vd = 5;
rd = .1;

[vdhat,vahat,t_int,t_rem,success] = intercept(xd,Vd,xa,Va,xr,rd);
if success
    t = linspace(0,t_int,100);
    x1 = xd(1) + Vd*vdhat(1)*t;
    y1 = xd(2) + Vd*vdhat(2)*t;
    x2 = xa(1) + Va*vahat(1)*t;
    y2 = xa(2) + Va*vahat(2)*t;
    plot(x1,y1); hold on;
    plot(x2,y2,'r');
    if rd>0
        th = linspace(0,2*pi,100);
        plot(rd*cos(th)+x1(end),rd*sin(th)+y1(end));
    end
end



