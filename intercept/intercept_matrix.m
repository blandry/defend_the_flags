function [IM,a,d] = intercept_matrix(a,d,r,t)
% Given d, a, r compute intercept points and related quantities
% Also give current time

D = numel(d);
A = numel(a);
IM = repmat(struct('vdhat',0,'vahat',0,'t_reach',0,'t_int',0,'t_rem',0,'flag',0), D, A);

for i=1:D
    for j=1:A
        xd = [d(i).x,d(i).y];
        xa = [a(j).x,a(j).y];
        xr = [r(a(j).t).x,r(a(j).t).y];
        
        % Compute intercept point for d_i and a_j
        [vdhat,vahat,t_reach,t_int,t_loss,success] = intercept(xd,d(i).V,xa,a(j).V,xr,d(i).R);
        IM(i,j).vdhat = vdhat;
        IM(i,j).vahat = vahat;
        IM(i,j).t_reach = t_reach + t; % Add to current time
        IM(i,j).t_int = t_int + t; % Add to current time
        IM(i,j).t_rem = max(0,t_loss - t_reach); % How long defender has after reaching attacker
        IM(i,j).flag = success;
        if sum([a.active]) == 2 && i==1
            continue
        end
        
        if xd(1) == xa(1) && xd(2) == xa(2) % already intercepted
            IM(i,j).flag = 1;
            IM(i,j).t_int = t;
            IM(i,j).vdhat = vahat;
        end
        
        % Record the time that attacker will hit its target
        a(j).t_destroy = t_loss + t;
    end
end

end

