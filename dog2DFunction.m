function DoGFunc = dog2DFunction(params, inputX, inputY)
%Returns a DoG function which can be directly inputted to surf() or
%imagesc(). Requires params which must be:
%sigmaX1 = params(1);
%sigmaX2 = params(2);
%x0 = params(3);
%y0 = params(4);
%amp1 = params(5);
%amp2 = params(6);
%
%Notice that there are only 2 SDs instead of 4. This is temporary so as to
%make the curve fits better. TODO: CURVE FIT FOR 4 SDs
%
%inputY is OPTIONAL because otherwise this wouldn't work with
%lsqcurve fit due to the fact that it can only take one input. This has an
%interest consequence. In order to use lsqcurvefit with this function, you
%have to pass in a flattened x and a flattened y in the form:
%[flatten(x);flatten(y)]. This is because the input into lsqcurve fit must
%have the same number of cols as the output function. but this says
%nothing of rows. So what we do below is we check if we were given an
%'inputY' value. If we were, plot the function as usual; if not, then we
%know it's lsqcurve fit calling this function, so we unflatten the inputX
%and create two separate inputs as inputX and inputY
%
%Example of typical use:
%
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
%Written by Christian Gonzalez-Capizzi
%(christian.gonzalez.capizzi@gmail.com)

    if ~exist('inputY','var')
        inputY = inputX(2,:);
        inputX = inputX(1,:);
    end
    
    sigmaX1 = params(1);
    sigmaY1 = sigmaX1;
    sigmaX2 = params(2);
    sigmaY2 = sigmaX2;
    x0 = params(3);
    y0 = params(4);
    X = inputX;
    Y = inputY;
    
    if ~(exist('params(7)', 'var') && exist('params(8)', 'var'))
        amp1 = .6;
        amp2 = .5;
    else
        amp1 = params(5);
        amp2 = params(6);
    end
    
    DoGFunc = amp1*exp(-((X-x0).^2/(2*sigmaX1^2)+(Y-y0).^2/(2*sigmaY1^2))) - amp2*exp(-((X-x0).^2/(2*sigmaX2^2)+(Y-y0).^2/(2*sigmaY2^2)));
end