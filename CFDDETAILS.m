function cfdRectangleCylinderExample()

%This MATLAB script defines a function called cfdRectangleCylinderExample
% that simulates a fluid flow scenario using Computational Fluid Dynamics (CFD) principles
% to examine the impact of a cylindrical obstacle within a rectangular domain on the shear stress 
% distribution due to a uniform flow velocity. The script comprises three main parts:
% the main function that sets up the geometry and performs calculations, 
% and two additional functions dedicated to calculating shear stress and visualizing the results.

    % Define the rectangle geometry
    lengthRect = 107.6; % cm, updated based on requirements
    widthRect = 10.16; % cm
    heightRect = 5.08; % cm
% Define the EFA channel geometry:

    %lengthRect = 107.6; % cm, updated based on requirements: Defines 
    % the length of the EFA rectangular length in centimeters.
    %widthRect = 10.16; % cm: Defines the width of the rectangular channel in centimeters.
    %heightRect = 5.08; % cm: Defines the height of the rectangular domain in centimeters
    
    
    % Define the cylinder geometry
    diameterCyl = 7.6; % cm, updated Shelby tube diameter
    radiusCyl = diameterCyl / 2;
    heightCylStart = -4; % cm
    heightCylEnd = 0.0; % cm

    % Single velocity value
    velocity = 200; % cm/s

    % Create a new figure
    figure;

    % Create a 3D mesh grid for the rectangle
    [X, Y, Z] = meshgrid(-50:0.1:50, -widthRect/2:0.1:widthRect/2, -heightRect/2:0.1:heightRect/2);

    % Adjust Z for cylinder's starting and ending points
     %Adjusts the Z-coordinates of the mesh grid by subtracting half the height of the rectangle,
    % aligning it with the cylinder's vertical position.

      %  Adjusts the Z-coordinates of the mesh grid 
    % by subtracting half the height of the rectangle, 
    % aligning it with the cylinder's vertical position
    ZCylAdjusted =  Z- heightRect/2;


    % Calculate cylinder center position from the edge
    %This code Determines the X-coordinate of the cylinder's center by offsetting from one edge of
    % the rectangle, taking into account the cylinder outter wall
    % to ensure it is fully within the domain.
    
    cylCenterXPos = -lengthRect/2 + 75 ; 
  

    % Create a logical mask for the cylinder's volume
    circleMask = sqrt(((X - cylCenterXPos).^2) + ((Y).^2)) <= radiusCyl & ZCylAdjusted >= heightCylStart & ZCylAdjusted <= heightCylEnd;
%The goal of this line is to create a logical array (or mask) 
% that identifies which points in a 3D mesh grid fall within the cylindrical region 
% defined by its geometric parameters (radius, and start and end heights). 
% This mask is later used to apply specific calculations (like shear stress) 
% only to the points that are within the cylinder, 
% distinguishing them from the rest of the rectangle.
    % Calculate shear stress

 %sqrt(((X - cylCenterXPos).^2) + ((Y).^2)): 
 % This portion computes the Euclidean distance of each point in the mesh grid 
 % from the center of the cylinder's base. The center of the cylinder is offset 
 % along the X-axis by cylCenterXPos. The .^2 squares each element of the matrices,
 % ensuring the operation is element-wise. T
 % Taking the square root of their sum gives the distance from the center 
 % of the cylinder in the XY plane.

    shearStress = calculateShearStress(X, Y, velocity, circleMask, lengthRect, widthRect, 0.05, 0.00001);

    % Visualization for the single velocity
    %This function visualizes the geometry and shear stress distribution.
    visualizeGeometryWithShearStress(X, Y, Z, circleMask, shearStress, velocity);
end

function shearStress = calculateShearStress(X, Y, velocity, mask, lengthRect, widthRect, roughnessIn, roughnessOut)
    % Calculate the distance from the edges of the rectangle along the X-axis
    %%% function with the mesh grid coordinates, velocity, and the cylinder mask to 
    % compute the shear stress distribution caused by the fluid flow
    %%In fact, this function computes the shear stress 
    % distribution across the rectangular domain based on the specified geometry, 
    % flow velocity, and the presence of the cylindrical obstacle.

    distanceFromEdgeX = min(abs(X + lengthRect/2), abs(X - lengthRect/2));

    % Normalize this distance using the half of the rectangle's length. 
    % Normalizes the distance to a range between 0 and 1 by dividing by half the rectangle's length.
    normalizedDistance = distanceFromEdgeX / (lengthRect / 2);



    % Calculate shear stress based solely on the X-direction distance and velocity
    % Calculates shear stress as a function of velocity and distance from the edge, 
    % assuming it decreases linearly from the edge 
     % Assuming shear stress decreases with distance from the edge along the X-axis
    shearStress = velocity * (1 - normalizedDistance); 
   

    % Apply roughness factors based on the mask
    %Apply roughness factors based on the mask:
    %Applies different roughness multipliers to shear stress inside (roughnessIn) 
    % and outside (roughnessOut) the cylinder to model 
    % the effect of surface roughness on shear stress.

    shearStress(mask) = shearStress(mask) * roughnessIn; % Roughness inside cylinder
    shearStress(~mask) = shearStress(~mask) * roughnessOut; % Roughness outside cylinder
end


function visualizeGeometryWithShearStress(X, Y, Z, mask, shearStress, velocity)%

%This function visualizes the geometry and shear stress distribution.

    %Flatten arrays for scatter3:
     %X = X(:); Y = Y(:); Z = Z(:); shearStress = shearStress(:);: 
     % Converts the 3D arrays into vectors to be used in the scatter3 function for plotting.

    X = X(:);
    Y = Y(:);
    Z = Z(:);
    shearStress = shearStress(:);
     %Use scatter3 to plot:
  %   scatter3(X, Y, Z, 20, shearStress, 'filled');: 
  % Plots the 3D scatter of shear stress distribution with color-coded points 
  % based on the magnitude of shear stress.
    % Use scatter3 to plot
    %Set aspect ratio, labels, and add color bar:
    %Configures the plot with equal aspect ratio, labels for each axis, 
    % a title indicating the velocity, and a color bar 
    % representing the scale of shear stress values. 
    % The colormap function is used to define the color scheme for the color-coded data points.

    scatter3(X, Y, Z, 20, shearStress, 'filled'); % Adjusted point size for better visibility


    % Flatten arrays for scatter3
    % Set aspect ratio, labels, and add color bar
    daspect([1,1,1]);
    xlabel('X (cm)');
    ylabel('Y (cm)');
    zlabel('Z (cm)');
    title(sprintf('Velocity = %d cm/s, Shear Stress Distribution', velocity));
    colormap(jet);
    colorbar;
    caxis([min(shearStress), max(shearStress)]);
    ylabel(colorbar, 'Shear Stress (Pa)');
end
