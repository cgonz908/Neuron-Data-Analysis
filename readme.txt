Contents include scripts from various authors, all of which are used by the main two scripts “loadData.m” and “fitDog2D.m” (DoG = difference of Gaussians)

autoGaussianSurf.m is a Gaussian curve fitting software used in fitDog2D.m and full credit belongs to Patrick Mineault. 

fitgabor2d.m is a gabor curve fitting software. This and all it’s dependencies have fully credited to Kendrick Kay

HartigansDipSignifTest.m and it’s dependency is also not my work, however I do not know who the original author was.

Info on main scripts:

loadData.m is a script that can handle hundreds of receptive field neuron data at once. Simply drop all files into the specified folder and run the script to get an output of: A plot of the first 8 receptive field lags, the peak lag (the most gabor/dog like), the best curve fit, and the residual. Finally, any data pulled from the file (such as orientation bias, ZMN exponent, etc.) can be plotted as a scatter plot, or histogram. If plotted as a histogram there is built in functionality to determine if there is bimodal distribution of the plotted data. The code allows for easy addition of any other data points one would like to track. Furthermore, the values of each curve fit function can be easily saved to reduce data by many orders of magnitude. 

fitDog2D.m curve fits a DoG function to an inputted kernel data typically from a receptive field from a give neuron. This function automatically picks guesses which are then curve fitted using lsqcurvefit. The initial guesses are highly accurate, as is the output with the exception of the amplitude. Currently the amplitude may be off by a varying factor. This fix is on the todo list, but can be simply fixed by scaling up the resultant curve fit. However all other values will remain accurate. 

dog2DFunction.m is a versatile function that allows a simple output of a dog function given parameters, or the ability to be passed into lsqcurvefit without any further modification

~Written by Christian Gonzalez-Capizzi (christian.gonzalez.capizzi@gmail.com)