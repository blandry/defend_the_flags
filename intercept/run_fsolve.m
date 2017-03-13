function [t_int, Vdy, Vdx, flag] = run_fsolve(xd, Vd, xa, Vatt, Vdef_guess)
% Call fsolve and check a couple solutions to find the best

B = [1 -1];
flag = 0;
% Solve
options = optimoptions('fsolve','Display','off');
for i=1:2
    % Function to solve for interception point
    b = B(i);
    fun = @(Vdy) (Vatt(2)-Vdy).*(xd(1)-xa(1)) + ...
        (b*sqrt(Vd.^2-Vdy.^2)-Vatt(1)).*(xd(2)-xa(2));

    [Vdy1,~,exitflag1,~] = fsolve(fun,Vdef_guess(2),options);
    [Vdy2,~,exitflag2,~] = fsolve(fun,-Vdef_guess(2),options);
    Vdy_possible = [Vdy1 Vdy2];
    t_int1 = (xd(2)-xa(2))/(Vatt(2)-real(Vdy1));
    t_int2 = (xd(2)-xa(2))/(Vatt(2)-real(Vdy2));	
    if exitflag1 == 1 && exitflag2 == 1
        if t_int1 > 0 && t_int2 > 0
            [t_int, idx] = min([t_int1 t_int2]);
            Vdy = Vdy_possible(idx);
            Vdx = b*real(sqrt(Vd^2 - real(Vdy)^2));
            flag = 1;
            break
        elseif t_int1 > 0
            t_int = t_int1;
            Vdy = Vdy1;
            Vdx = b*real(sqrt(Vd^2 - real(Vdy)^2));
            flag = 1;
            break
        elseif t_int2 > 0
            t_int = t_int2;
            Vdy = Vdy2;
            Vdx = b*real(sqrt(Vd^2 - real(Vdy)^2));
            flag = 1;
            break
        end 
    elseif exitflag1 == 1 && exitflag2 ~= 1 && t_int1 > 0
        t_int = t_int1;
        Vdy = Vdy1;
        Vdx = b*real(sqrt(Vd^2 - real(Vdy)^2));
        flag = 1;
        break
    elseif exitflag1 ~= 1 && exitflag2 == 1 && t_int2 > 0
        t_int = t_int2;
        Vdy = Vdy2;
        Vdx = b*real(sqrt(Vd^2 - real(Vdy)^2));
        flag = 1;
        break
    end
    Vdy = 0;
    Vdx = 0;
    t_int = 0;
end

end

