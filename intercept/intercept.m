function [vdhat,vahat,t_reach,t_int,t_loss,success] = intercept(xd, Vd, xa, Va, xr, rd)
%Computes the velocity unit vector for a defender
%   [vdhat,t,flag] = intercept(xd,Vd,xa,Va,xr,rd) where xd is position vector of
%   defender, Vd is defender speed, xa is attacker position, Va is attacker
%   speed, xr is resource position for the attacker, rd (optional) is the reach of the
%   defender

% Compute attacker velocity vector
rel = xr-xa;
vahat = rel./norm(rel,2);
Vatt = Va*vahat;

% Compute guess for Vdy
mid = (xr+xa)./2 - xd;
Vdef_guess = Vd*mid./norm(mid,2);

[t_int, Vdy, Vdx, flag] = run_fsolve(xd, Vd, xa, Vatt, Vdef_guess);

% Check output
t_loss = norm(rel,2)/Va;
if flag > 0 && t_int < t_loss
    vdhat = [Vdx, real(Vdy)]./Vd;

    % Compute updated intercept time based on defender reach
    if nargin > 5
        % Soonest interept time
        theta = atan2d(norm(cross([vdhat 0],[vahat 0])),dot(vdhat,vahat));
        if theta < 90
            x_left = rd/sind(theta);
        else
            x_left = rd;
        end
        t = linspace(t_int-x_left/Vd,t_int,100);
        a_pos = [xa(1) + Va*vahat(1)*t; xa(2) + Va*vahat(2)*t];
        d_pos = [xd(1) + Vd*vdhat(1)*t; xd(2) + Vd*vdhat(2)*t];
        relpos = a_pos - d_pos;
        for i=1:length(relpos)
            if norm(relpos(:,i),2) < rd
                break;
            end
        end
        t_reach = t(i);  
    end
    success = 1;
else
    vdhat = [0 0];
    t_reach = 0;
    t_int = 0;
    success = 0;
end

end

