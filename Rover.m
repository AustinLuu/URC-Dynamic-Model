classdef Rover < handle
    %Sample Input: a=Rover(50,[0.05739,-0.00179],0,0,[1.31;1.31;1.31;],[0.05769;0.05769;1.023569;],[0;0;0.16493],z)
    %z = [0.54273 -0.23162 0.45582 -0.03399 0.39958 0.09389 0 0;
    % 0.10203 -0.23160 0.08405 -0.03485 0.24526 0.09388 0 0;
    % -0.34858 -0.23261 0.32241 -0.06357 0.32242 0.03803 0.001 0.15557;]
    %Rover Summary: This class Detailed explanation goes heredefines a rover object under which forces are determined for linkages, connectors, and wheels as per the defined functions
    properties
        mass; %Mass of entire rover in KG
        cog; %Center of Gravity for rover assembly [x y] in Meters (m)
        imp; %Impact force if applicable [X Y] in Newtons (N)
        sce; %0 = Default Static Case, rover not moving
             %1 = Rover driving full force impact on front 2 wheels
             %2 = Rover driving full force impact on back 2 wheels
             %3 = Rover Landing on all 6 wheels from a height
             %4 = Rover Landing on 4 front wheels from a height
             %5 = Rover Landing on 4 back wheels from a height
             %6 = Rover landing on 2 front wheels from a height
             %7 = Rover landing on 2 back wheels from a height
        wmass; %Mass of wheels [W1;W2;W3;]
        lmass; %Mass of links [L1;L2;L3;]
        cmass; %Mass of connectors [C4;C5;C1;]
        
        sect; %intersection points between all parts [J1W1X J1W1Y J1C1X J1C1Y J1C4X J1C4Y 0 0;
                                                     %J2W2X J2W2Y J2C1X J2C1Y J2C5X J2C5Y 0 0; 
                                                     %J3W3X J3W3Y J3C1X J3C1Y J3C45X J3C45Y J3C3X J3C3Y;]
  
        wforce; %Forces acting on the wheel[ff1 ff2 ff3;fn1 fn2 fn3;fl1x fl2x fl3x; fl1y fl2y fl3y;]
        lforce %Forces acting on the linkages[fw1x fw2x fw3x;
                                             %fw1y fw2y fw3y;
                                             %fgl1 fgl2 fgl3;
                                             %fc1x1 fc1x2 fc1x3;
                                             %fc1y1 fc1y2 fc1y3;
                                             %fc4x1 0 fc4x3;
                                             %fc4y1 0 fc4y3;
                                             %0 fc5x2 fc5x3;
                                             %0 fc5y2 fc5y3;
                                             %0 0 fc3x3;
                                             %0 0 fc3y3;]
        cforce %Forces acting on the connectors [J1C4X J3C4X 0 0;
                                                %J1C4Y J3C4X 0 0;
                                                %J2C5X J3C5X 0 0;
                                                %J2C5Y J3C5X 0 0;
                                                %J1C1X J2C1X J3C1X 0;
                                                %J1C1Y J2C1Y J3C1Y FG;]
        g = -9.81; %Setting gravity constant
        mu = 0.8; %Setting coefficient of static friction between ruber and sand
    end
    
    methods
        
        function obj = Rover(Mass,COG,Impact,Scenario,WheelMass,LinkMass,ConnMass,Intersection)
            %Rover: Construct an instance of this class
            %Associating Rover object paramaters
            if nargin > 0
                obj.mass = Mass;
                obj.cog = COG;
                obj.imp = Impact;
                obj.sce = Scenario;
                obj.wmass = WheelMass;
                obj.lmass = LinkMass;
                obj.cmass = ConnMass;
                obj.sect = Intersection;
            end
            %Building force model
            obj.wheelForce;
            obj.linkForce;
        end
        
        function wheelForce(rov)
            %The following function solves for all corresponding forces acting on the three rover wheels
            %The calculations vary for each scenario, friction only applies to scenario 0
            %solving for known constants
            fgt = (rov.mass*rov.g)/2;
            x1 = rov.cog(1,1)-rov.sect(1,1);
            x2 = rov.cog(1,1)-rov.sect(2,1);
            x3 = rov.cog(1,1)-rov.sect(3,1);
            
            if rov.sce == 0 || rov.sce == 1 || rov.sce == 2
                %Solving for normal forces:
                %A,B: For assumed subsystem eqs(force and moment)
                %a,b: For all three wheels eqs(force, moment, FN3)
                A = [1 1;(x1+x2)/2 x3;];
                B = [-fgt;0;];
                fn = linsolve(A,B);
                a = [1 1 1; x1 x2 x3;0 0 1;];
                b = [-fgt;0;fn(2,1);];
                fn = linsolve(a,b);
                %Solving for frictional forces
                temp = (fn(1,1)*abs(x1) + fn(2,1)*abs(x2) + fn(3,1)*abs(x3));
                %Solving for the fractional value of the frictional forces
                ff(1,1) = fn(1,1)*x1/temp;
                ff(2,1) = fn(2,1)*x2/temp;
                ff(3,1) = fn(3,1)*x3/temp;
                %Solving for the frictional forces
                ff(1,1) = ff(1,1)*min(fn)*rov.mu;
                ff(2,1) = ff(2,1)*min(fn)*rov.mu;
                ff(3,1) = ff(3,1)*min(fn)*rov.mu;
                for i = 1:3
                    rov.wforce(1,i) = ff(i,1);
                    rov.wforce(2,i) = fn(i,1);
                    rov.wforce(3,i) = -ff(i,1); %since only friction acts in the horizontal direction, linkage is equiv.
                    rov.wforce(4,i) = -fn(i,1)-rov.g*rov.wmass(i,1); %compensating for affect of gravity
                end
                if rov.sce == 1
                    rov.wforce(1,3) = rov.imp(1,1)/2;
                    rov.wforce(3,3) = -rov.imp(1,1)/2; %since the impact force affects the front 2 wheels
                elseif rov.sce == 2
                    rov.wforce(1,1) = rov.imp(1,1)/2;
                    rov.wforce(3,1) = -rov.imp(1,1)/2; %since the impact force affects the back 2 wheels
                end
            elseif rov.sce == 3
                %solving for force reaction on the forces due to a drop impact force on 6 wheels
                for i = 1:3
                    rov.wforce(2,i) = rov.imp(1,2)/6;
                    rov.wforce(4,i) = -rov.wforce(2,i)-rov.g*rov.wmass(i,1);
                end
            elseif rov.sce == 4
                %solving for force reaction on the forces due to a drop impact force on 4 front wheels
                for i = 2:3
                    rov.wforce(2,i) = rov.imp(1,2)/4;
                    rov.wforce(4,i) = -rov.wforce(2,i)-rov.g*rov.wmass(i,1);
                end
                rov.wforce(4,1) = -rov.g*rov.wmass(1,1);
            elseif rov.sce == 5
                %solving for force reaction on the forces due to a drop impact force on 4 back wheels
                for i = 1:2
                    rov.wforce(2,i) = rov.imp(1,2)/4;
                    rov.wforce(4,i) = -rov.wforce(2,i)-rov.g*rov.wmass(i,1);
                end
                rov.wforce(4,3) = -rov.g*rov.wmass(3,1);
            elseif rov.sce == 6
                %solving for force reaction on the forces due to a drop impact force on 2 front wheels
                rov.wforce(2,3) = rov.imp(1,2)/2;
                rov.wforce(4,3) = -rov.wforce(2,3)-rov.g*rov.wmass(3,1);
                rov.wforce(4,1) = -rov.g*rov.wmass(1,1);
                rov.wforce(4,2) = -rov.g*rov.wmass(2,1);
            elseif rov.sce == 7
                %solving for force reaction on the forces due to a drop impact force on 2 back wheels
                rov.wforce(2,1) = rov.imp(1,2)/2;
                rov.wforce(4,1) = -rov.wforce(2,1)-rov.g*rov.wmass(1,1);
                rov.wforce(4,2) = -rov.g*rov.wmass(2,1);
                rov.wforce(4,3) = -rov.g*rov.wmass(3,1);
            end
        end
        
        function linkForce(rov)
            %The following function solves for all corresponding forces acting on the two identical linkages
            %The calculations are the same for each scenario
            %setting solved wheel force variables and solving for g-forces
            theta(1,1) = atan2d(rov.sect(1,6)-rov.sect(3,6),rov.sect(1,5)-rov.sect(3,5)); %returns values in the closed interval [-180,180] based on the values of Y and X 
            theta(1,2) = atan2d(rov.sect(2,6)-rov.sect(3,6),rov.sect(2,5)-rov.sect(3,5)); %Solves for Theta C4 and C5 make wrt the X-axis
            for i = 1:3
                rov.lforce(1,i) = -rov.wforce(3,i);
                rov.lforce(2,i) = -rov.wforce(4,i);
                rov.lforce(3,i) = rov.g*rov.lmass(i,1);
            end
            
            %solving for connector forces on L1 and L2
            %[Sum of X-forces;Sum of Y-forces;Sum of moments;]
            for i = 1:2
                cogx = (rov.sect(i,1)+rov.sect(i,5))/2; %det COG of the link
                cogy = (rov.sect(i,2)+rov.sect(i,6))/2; %det COG of the link
                a = [1 0 cosd(theta(1,i));0 1 sind(theta(1,i));0 0 -sind(theta(1,i))*(rov.sect(i,5)-rov.sect(i,3))+cosd(theta(1,i))*(rov.sect(i,6)-rov.sect(i,4))];%matrix for [sof in x; sof in y; som about C1;]
                b = [-rov.lforce(1,i);-rov.lforce(2,i)-rov.lforce(3,i);-rov.lforce(1,i)*(rov.sect(i,2)-rov.sect(i,4))+rov.lforce(2,i)*(rov.sect(i,1)-rov.sect(i,3))+rov.lforce(3,i)*(cogx-rov.sect(i,3));];%note for moments, due to cross product xforces changes sign
                temp = linsolve(a,b); %[fc1x fc1y fc4]
                rov.lforce(4,i) = temp(1,1); %Assigning Fc1x force
                rov.lforce(5,i) = temp(2,1); %Assigning Fc1y force
                rov.lforce(6+(i-1)*2,i) = temp(3,1)*cosd(theta(1,i)); %Assigning connector 4/5 x force
                rov.lforce(7+(i-1)*2,i) = temp(3,1)*sind(theta(1,i)); %Assigning connector 4/5 y force
            end
            
            rov.connForce; %solving connector reaction forces
            %Solving the remaining forces, on linkage 3, determining conn rod forces
            for i = 4:9
                rov.lforce(i,3) = rov.cforce(i-3,3);
            end
            rov.lforce(10,3) = 0 - rov.lforce(1,3) - rov.lforce(4,3) - rov.lforce(6,3) - rov.lforce(8,3);
            rov.lforce(11,3) = 0 - rov.lforce(2,3) - rov.lforce(3,3) - rov.lforce(5,3) - rov.lforce(7,3) - rov.lforce(9,3);
            disp(rov.lforce);
            fprintf('Conn Rod X-Force: %3.3s Conn Rod Y-Force: %3.3d\n',rov.lforce(10,3),rov.lforce(11,3));
        end
        
        function connForce(rov)
            %Assigning c4 and c5 reaction forces
            for i = 1:2
                rov.cforce(i*2+1,1) = -rov.lforce(6+(i-1)*2,i); %assigning x-reaction force from linkage
                rov.cforce(i*2+1,3) = rov.lforce(6+(i-1)*2,i); %assigning x-reaction force to linkage
                rov.cforce(i*2+2,1) = -rov.lforce(7+(i-1)*2,i); %assigning y-reaction force from linkage
                rov.cforce(i*2+2,3) = rov.lforce(7+(i-1)*2,i); %assigning y-reaction force from linkage
                rov.cforce(i*2+2,4) = rov.g*rov.cmass(i,1); %assigning FOG-reaction force from linkage mass
            end
            rov.cforce(1,1) = -rov.lforce(4,1); %solving the x-forces acting on C1
            rov.cforce(1,2) = -rov.lforce(4,2);
            rov.cforce(1,3) = 0 -rov.cforce(1,1) -rov.cforce(1,2);
            rov.cforce(2,1) = -rov.lforce(5,1); %solving the y-forces acting on C1
            rov.cforce(2,2) = -rov.lforce(5,2);
            rov.cforce(2,4) = rov.g*rov.cmass(3,1);
            rov.cforce(2,3) = 0 -rov.cforce(2,1) -rov.cforce(2,2) -rov.cforce(2,4);
        end
    end
end

