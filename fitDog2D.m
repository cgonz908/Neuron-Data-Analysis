function [finalDoG, finalVals] = fitDog2D(input)
%Written by Christian Gonzalez-Capizzi
%
%Relies on autoGaussianSurf by Patrick Mineault
%
%Fits a DoG (Difference of Gaussians) to an inputted matrix with automatic guesses. 
%
%The initial guesses are taken care of automatically for: standard deviation-x, y for
%both Gaussians as well as the offset of the center. 
%
%The two amplitudes are also automatically guessed but isn't running efficiently so the resultant
%function may have to be scaled up or down by a few orders of magnitude.
%the output of fitDog2D is [finalDoG, finalVals]. finalDoG can be plotted
%with either surf or imagesc. finalVals give 8 values: 
%
%1) sdx1 2)sdx2 3)x-offset 4) y-offset 5) amplitude1 6)amplitude2
%
%Example: 
% params(1) = 2;
% params(2) = 1.2*2;
% params(3) = 18;
% params(4) = 17;
% params(5) = 6;
% params(6) = 5;
% 
% res = 32;
% 
% [xVals, yVals] = meshgrid(1:1:res);
% 
% figure(1);
% Z = dog2DFunction(params, xVals, yVals);
% surf(Z);
% title('Created DoG');
% 
% %Fit
% [fittedDoG, values] = fitDog2D(double(Z));
% figure(2);
% surf(fittedDoG);
% title('Created DoG Fit');
%
%Dependent on autoGaussianSurf by Patrick Mineault 
%
%Written by Christian Gonzalez-Capizzi
%(christian.gonzalez.capizzi@gmail.com)
    Z = input;
    
    %Find image resolution
    res = size(Z,1);

    % construct coordinates, this way the cords of the image are the same
    % as the index of the rows & cols of the input kernel
    [xVals, yVals] = meshgrid(1:1:res);

    %Guesses for x and y offset 
    [trash1, maxYIndex] = max(max(abs(Z))); 
    [trash2, maxXIndex] = max(abs(Z(:, maxYIndex)));
     guess(3) = maxXIndex;
     guess(4) = maxYIndex;

    [xSize, ySize] = size(Z);

    % % % For guess(1): 1) find peak value 2) determine if it's on or off
    % center (+ or -) 3) half-way rectify (clip all negatives if on center
    % peak, clip all positive if off center peak) 4)fit 2D Gaussian to the
    % remaining function 5) Pull std from that

    rectifiedZ = Z;

    %Find if peak is on or off center (+ or -)
    if Z(maxXIndex, maxYIndex) > 0 %on center is peak
        %Clip everything below zero
        for xIndex = 1:xSize
            for yIndex = 1:ySize
                if rectifiedZ(xIndex, yIndex) < 0
                    rectifiedZ(xIndex, yIndex) = 0;
                end
            end
        end
    elseif Z(maxXIndex, maxYIndex) < 0
        %Clip everything above zero
        for xIndex = 1:xSize
            for yIndex = 1:ySize
                if rectifiedZ(xIndex, yIndex) > 0
                    rectifiedZ(xIndex, yIndex) = 0;
                end
            end
        end
    else
        error('Peak value is 0 or imaginary, something went wrong');
    end
    
    %Fit the rectified function which should look like a Gaussian
    fittedGaussian = autoGaussianSurf(xVals, yVals, double(rectifiedZ));

    %Guesses for amplitude and SD
    if Z(maxXIndex, maxYIndex) > 0 %If positive peak 
        guess(5) = max(max(Z));
        guess(6) = guess(5)*.8;
        
        guess(1) = fittedGaussian.sigmax;  
        guess(2) = 1.2*guess(1); 
    else %If negative peak
        guess(6) = max(max(abs(Z)));
        guess(5) = guess(6)*.8;
        
        guess(2) = fittedGaussian.sigmax;
        guess(1) = guess(3)*.8;
    end

    %This is where the curve fit actually happens. The key here is
    %"[flatten(xVals); flatten(yVals)], flatten(Z)"
    %The reason for this is that lsqcurvefit can't take an input
    %(i.e. [flatten(xVals); flatten(yVals)]) that is not the same # of cols
    %as the output (i.e. flatten(Z)). But it says nothing of the rows. So
    %we pass in our second input variable ('yVals') as a second row to the
    %input. Then inside the dog2DFunction we expand the one input into two.
    fittedVals2 = lsqcurvefit(@dog2DFunction, guess, [flatten(xVals); flatten(yVals)], flatten(Z));

    finalVals.sdx1 = fittedVals2(1);
    finalVals.sdx2 = fittedVals2(2);
    finalVals.x0 = fittedVals2(3);
    finalVals.y0 = fittedVals2(4);
    finalVals.amp1 = fittedVals2(5);
    finalVals.amp2 = fittedVals2(6);
    finalDoG = dog2DFunction(fittedVals2, xVals, yVals);
end