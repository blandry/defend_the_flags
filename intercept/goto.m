function [d] = goto(d,loc,t_current)
% Given defender and location, compute protocol to get there
xd = [d.x, d.y];
rel = loc-xd;
vdhat = rel./norm(rel,2);
t_int = norm(rel,2)/d.V;

% Set
d.vdhat = vdhat;
d.t_int = t_int+t_current;
end

