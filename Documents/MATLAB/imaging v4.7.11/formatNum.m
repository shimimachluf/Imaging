function [out] = formatNum(num, units, fShort)

%uints: 3 letters string
%   'num': atom number (output in 10^6, 10^3, or nothing)
%   'dis': distance in meter (output in m, mm, /mum, or nm)

if nargin < 3
    fShort = 0;
end

switch units
    case 'num'
        if num > 10^6
            out = [num2str(num*10^-6) '*10^6'];
        elseif num > 10^3
            out = [num2str(num*10^-3) '*10^3'];
        else
            out = num2str(num);
        end
    case 'dis'
        if num > 1
            out = [num2str(num) ' m'];
        elseif num > 10^-3
            out = [num2str(num*10^3) ' mm'];
        elseif num > 10^-6
            if fShort
                out = [num2str(round(num*10^6)) ' \mum'];
            else
                out = [num2str(num*10^6) ' \mum'];
            end
        else
            out = [num2str(num*10^9) ' nm'];
        end
end
        

