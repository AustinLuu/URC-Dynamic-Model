README

MATLAB ROVER FORCE MODEL

file: Rover.m
documentation: p1.jpg , p2.jpg , p3.jpg , p4.jpg , ref.jpg
disclaimer: The following documentation is in regards to the R3 Mars Rover and should only be used and/or in possession of authorized members of the Ryerson Rams Robotics organization.
description: The Matlab file; Rover.m builds a simulated force model of the R3 Mars Rover based on inputs in accordance to the reference diagram (ref.jpg) following the below template.
potential improvement: 
 - Development of geometrical model to develop mars rover model of varying dimensions
 - Autodetermination of rovers COM
 - Implementation of autodetermination for maximum and minimum force loading

Instructions:
1. Determine the coordinates of all the highlighted points on the refernce diagram per your scenario (sample location is provided below)
2. Create matlab rover object with following inputs: RoverMass,RoverCOG,ImpactForce,Scenario,WheelMass,LinkMass,ConnMass,Intersection


------------------------------------------------------------------------------------------------------------------------------------------------


Input Template: obj = Rover(Mass,COG,Impact,Scenario,WheelMass,LinkMass,ConnMass,Intersection)

  Scenarios; %0 = Default Static Case, rover not moving
             %1 = Rover driving full force impact on front 2 wheels
             %2 = Rover driving full force impact on back 2 wheels
             %3 = Rover Landing on all 6 wheels from a height
             %4 = Rover Landing on 4 front wheels from a height
             %5 = Rover Landing on 4 back wheels from a height
             %6 = Rover landing on 2 front wheels from a height
             %7 = Rover landing on 2 back wheels from a height


-------------------------------------------------------------------------------------------------------------------------------------------------


Sample Input 0: a=Rover(50,[0.05739,-0.00179],0,0,[1.31;1.31;1.31;],[0.05769;0.05769;1.023569;],[0;0;0.16493],z)
    z = [0.54273 -0.23162 0.45582 -0.03399 0.39958 0.09389 0 0;
     0.10203 -0.23160 0.08405 -0.03485 0.24526 0.09388 0 0;
     -0.34858 -0.23261 0.32241 -0.06357 0.32242 0.03803 0.001 0.15557;]

Sample Input 1: a=Rover(50,[0.05739,-0.00179],[3000,0],1,[1.31;1.31;1.31;],[0.05769;0.05769;1.023569;],[0;0;0.16493],z)
    z = [0.54273 -0.23162 0.45582 -0.03399 0.39958 0.09389 0 0;
     0.10203 -0.23160 0.08405 -0.03485 0.24526 0.09388 0 0;
     -0.34858 -0.23261 0.32241 -0.06357 0.32242 0.03803 0.001 0.15557;]

Sample Input 2: a=Rover(50,[0.05739,-0.00179],[3000,0],2,[1.31;1.31;1.31;],[0.05769;0.05769;1.023569;],[0;0;0.16493],z)
    z = [0.54273 -0.23162 0.45582 -0.03399 0.39958 0.09389 0 0;
     0.10203 -0.23160 0.08405 -0.03485 0.24526 0.09388 0 0;
     -0.34858 -0.23261 0.32241 -0.06357 0.32242 0.03803 0.001 0.15557;]

Sample Input 3: a=Rover(50,[0.05739,-0.00179],[0,4068],3,[1.31;1.31;1.31;],[0.05769;0.05769;1.023569;],[0;0;0.16493],z)
    z = [0.54273 -0.23162 0.45582 -0.03399 0.39958 0.09389 0 0;
     0.10203 -0.23160 0.08405 -0.03485 0.24526 0.09388 0 0;
     -0.34858 -0.23261 0.32241 -0.06357 0.32242 0.03803 0.001 0.15557;]

Sample Input 4: a=Rover(50,[0.05739,-0.00179],[0,4068],4,[1.31;1.31;1.31;],[0.05769;0.05769;1.023569;],[0;0;0.16493],z)
    z = [0.593 0.079 0.380 0.122 0.243 0.149 0 0;
     0.257 -0.327 0.250 -0.111 0.245 0.029 0 0;
     -0.282 -0.327 0.341 -0.009 0.318 0.090 -0.030 0.130;]

Sample Input 5: a=Rover(50,[0.05739,-0.00179],[0,4068],5,[1.31;1.31;1.31;],[0.05769;0.05769;1.023569;],[0;0;0.16493],z)
    z = [0.458 -0.380 0.384 -0.176 0.336 -0.045 0 0;
       -0.020 -0.380 0.120 -0.214 0.210 -0.108 0 0;
     -0.426 -0.072 0.256 -0.225 0.302 -0.134 0.060 0.119;]

Sample Input 6: a=Rover(50,[0.05739,-0.00179],[0,4068],6,[1.31;1.31;1.31;],[0.05769;0.05769;1.023569;],[0;0;0.16493],z)
    z = [0.609 -0.085 0.470 0.081 0.380 0.187 0 0;
      0.132 -0.085 0.206 0.119 0.253 0.250 0 0;
     -0.198 -0.384 0.334 0.070 0.288 0.161 -0.060 0.119;]

Sample Input 7: a=Rover(50,[0.05739,-0.00179],[0,4068],7,[1.31;1.31;1.31;],[0.05769;0.05769;1.023569;],[0;0;0.16493],z)
    z = [0.386 -0.479 0.397 -0.263 0.405 -0.123 0 0;
       0.039 -0.146 0.234 -0.052 0.360 0.009 0 0;
     -0.406 -0.146 0.292 -0.176 0.321 -0.078 0.038 0.128;]

