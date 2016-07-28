%function loadData()
% TODO: Calculate Z-value if Z-values isn't saved in neuron data; figure
% out why imagescZ doesn't behave properly for DoG Fits
%
%Relies on fitDog2D (Christian Gonzalez-Capizzi), fitgabor2d (Kendrick
%Kay) and HartigansDipSignifTest (unknown). Each of those may have dependencies listed in their documentation
%
%How to use: drop all neuron data (*.mat) in a folder, point the variable
%"fileList" to that folder, then press run. 
%
%This program is set up so that you can make multiple plots of specific
%data values (e.g. orientiation bias, etc.) found in neurons data
%
%Writted by Christian Gonzalez-Capizzi (Christian Gonzalez-Capizzi)
    clear variables; close all;

    %Make a collection of all files in directory wih the .mat ending; This
    %is where to drop the neuron data
    fileList = dir('/Users/christiangonzalez/Google Drive/MATLAB/*.mat');

    nFiles = length(fileList);

    plotIndex = 1; %Index for which plot in subplot(m, n, p) where p = plotIndex
    figNum = 1; %Used to change figure when current one is full
    %Dimensions of subplot, 6 files and 11 plots per file (lags 1-8, 9 is peak
    %lag, 10 is best fit, 11 is residual)
    m = 6;
    n = 11;
    
    %Collection of variables to plot at the end; Feel free to add more
    %variables to collect more data to plot at the end of the script
    phases = 0;
    nx = 0;
    ny = 0;
    zmn = 0;
    ob = 0;

    %For each file
    for fileIndex = 1:length(fileList)
        fName = fileList(fileIndex).name;

        %Actually load the file
        load(fName);

        %Find the peak lag (the most gabor-like), the '5' is the furthest
        %lag we will consider; note: the function findPeakLag starts
        %searching at lag #2
        peakLagIndex = findPeakLag(zScore.valueLag, 5);

        %Set Z to peak lag; we will use Z for curve fits after we plot
        %first 8 lags 
        Z = kernel2D(:, :, peakLagIndex);

        %Switch to correct figure
        figure(figNum);

        %Plot best fit
        %Roughly just expanisve oriented cells (see "Categorically distinct
        %types of receptive fields in early visual cortex" - Vargha, Baker)
        if tuningParams.ori.OBDB(1) >= .17 && fit.zmnStrf.m(2) >= 1.1 
            %Plot first 8 lags
            for lagIndex = 1:8
                subplot(m, n, plotIndex);
                imagesc(kernel2D(:,:,lagIndex)); colormap(fig.colormap); axis off;
                if lagIndex == 1 
                    title(fName);
                end
                plotIndex = plotIndex + 1;
            end
            
            %Then plot peak lag
            subplot(m, n, plotIndex);
            imagesc(kernel2D(:,:,peakLagIndex)); colormap(fig.colormap); axis off;
            title('Peak');
            plotIndex = plotIndex + 1;
            
            subplot(m, n, plotIndex);
            
            %Code pulled from fitgabor2d (Kendrick Kay) sample code
            dim = size(Z);
            [xx,yy] = calcimagecoordinates(dim(1));
            
            %Fit
            fittedVals = fitgabor2d(double(Z));
        
            %Scale up Gabor to make image more apparent
            imagesc(1000*evalgabor2d(fittedVals,xx,yy),[-2 2]); colormap(fig.colormap); axis off;
            title('Fit');
            plotIndex = plotIndex + 1;
            
            %Plot residual
            subplot(m, n, plotIndex);
            residual = Z-evalgabor2d(fittedVals,xx,yy);
            imagesc(residual); colormap(fig.colormap); axis off;
            title('Residual');
            plotIndex = plotIndex + 1;
            
            %Collect other interesting data; This is where you should
            %collect any extra data that you declared at the beginning of
            %the script
            phases = [phases fittedVals(3)];
            nx = [nx fittedVals(1)*fittedVals(6)];
            ny = [ny fittedVals(1)*fittedVals(7)];
            ob = [ob tuningParams.ori.OBDB(1)];
            zmn = [zmn fit.zmnStrf.m(2)];
        elseif tuningParams.ori.OBDB(1) <= .12 %Non oriented cells
            %Plot first 8 lags
            for lagIndex = 1:8
                subplot(m, n, plotIndex);
                imagesc(kernel2D(:,:,lagIndex)); colormap(fig.colormap); axis off;
                if lagIndex == 1 
                    title(fName);
                end
                plotIndex = plotIndex + 1;
            end
            
            %Then plot peak lag
            subplot(m, n, plotIndex);
            imagesc(kernel2D(:,:,peakLagIndex)); colormap(fig.colormap); axis off;
            title('Peak');
            plotIndex = plotIndex + 1;
            
            %fit DoG
            subplot(m, n, plotIndex);
            [DoG, fittedVals] = fitDog2D(double(Z));
            %This image is scaled up to make image more noticable, however
            %keep in mind that the amplitude returned from fitFog2D isn't
            %100% accurate
            imagescZ(100*DoG); colormap(fig.colormap); axis off;
            title('Fit');
            plotIndex = plotIndex + 1;
            
            %Plot residual
            subplot(m, n, plotIndex);
            residual = Z-DoG;
            imagesc(residual); colormap(fig.colormap); axis off;
            title('Residual');
            plotIndex = plotIndex + 1;
            
            %Collect other interesting data
            ob = [ob tuningParams.ori.OBDB(1)];
            zmn = [zmn fit.zmnStrf.m(2)];
        else
            %These are for compresive oriented cells (receptive fields are
            %"non descript")
        end

        %Reset where we will plot next graph if needed & start new window
        %if current window is full
        if plotIndex > (m*n)
            plotIndex = 1;
            figNum = figNum + 1;
        end
        drawnow;
    end
    
    %Plot any other data collected during calculations
    %Plot Phase vs Num of Neurons; histograms will display p-value for
    %biomodality using HartigansDipSignifTest
    figure(figNum+1);
    histogram(phases, 20);
    xlabel('Phase');
    ylabel('Number of Neurons');
    [dip, p] = HartigansDipSignifTest(phases, 500);
    title({'Phase vs. Number of Neurons', 'dip=',num2str(dip,3), ', p=',num2str(p,3)});
    
    %Plot Nx vs. Ny
    figure(figNum+2);
    scatter(nx, ny);
    xlabel('Major Axis Std * Frequency');
    ylabel('Minor Axis Std * Frequency');
    title('Nx vs. Ny');
    xlim([0, 1.5]);
    ylim([0, 1.5]);
    set(gca,'xscale','log');
    set(gca,'yscale','log');
    
    %Plot ZMN vs. Number of Neurons
    figure(figNum+3);
    histogram(zmn, 20);
    xlabel('ZMN Exponent');
    ylabel('Number of Neurons');
    [dip, p] = HartigansDipSignifTest(phases, 500);
    title({'ZMN vs. Number of Neurons', 'dip=',num2str(dip,3), ', p=',num2str(p,3)});
    
    %Plot OB vs. Number of Neurons
    figure(figNum+4);
    histogram(ob, 20);
    xlabel('Orientation Bias');
    ylabel('Number of Neurons');
    [dip, p] = HartigansDipSignifTest(phases, 500);
    title({'OB vs. Number of Neurons', 'dip=',num2str(dip,3), ', p=',num2str(p,3)});
%end