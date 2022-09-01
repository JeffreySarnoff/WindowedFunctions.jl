# Octave implementation of smoothing by a modified sinc
# kernel (MS), as described in M. Schmid, D. Rath and U. Diebold,
# 'Why and how Savitzky-Golay filters should be replaced',
# ACS Measurement Science Au, 2022 
#
# The term 'degree' (variable 'deg' to avoid conflict with the
# Matlab 'degree' function) is defined in analogy to Savitzky-Golay
# (SG) filters; the MS filters have a similar frequency response as SG filters
# of the same deg (2, 4, ... 10).
#
# Note: This file contains more than one function, therefore it is not a
# function file but rather a script file.
# For actual usage, delete the test code at the very end and
# include it in your code with 'source("modifiedSincSmoother.m")'
# When using only one smooth type (smoothMS _or_ smoothMS1),
# this file may be converted to a single-function file by renaming
# according to the name of the main function and placing the other
# functions as inner functions. The, delete the following line.
1;# this line avoids this being a single-function file.
#
# Copyright notice
# This code is licensed under GNU General Public License (GPLv3)
# When using and/or modifying this program for scientific work
# and the paper on it has been published, please cite the paper.
#
#  Author: Michael Schmid, IAP/TU Wien, 2021.
#          https://www.iap.tuwien.ac.at/www/surface/group/schmid


# This function smooths the data all the way to the boundaries
# by convolution with a MS kernel. Near-boundary values are handled
# by (weighted linear) extrapolation before convolution.
# 'data' should be a row vector (1xN).
# 'deg' degree, determines the sharpness of the cutoff in the frequency
# domain, similar to the degree of Savitzky-Golay filters.
# 'm' is the halfwidth of the kernel; higher values lead to
# stronger smoothing.
function smoothedData = smoothMS(data, deg, m)
  if (nargin != 3)
    error("Usage: smoothMS(dataRowVector, degree, m)");
  endif
  if (columns(data) < 2 || rows(data) != 1)
    error("Less than two data points or not a row vector");
  endif
  kernel = kernelMS(deg, m);
  fitWeights = edgeWeights(deg, m);
  extData = extendData(data, m, fitWeights);
  smoothedExtData = conv(extData, kernel, "same");
  smoothedData = smoothedExtData(m+1 : end-m);
endfunction

# The same with the shorter MS1 kernel
function smoothedData = smoothMS1(data, deg, m)
  if (nargin != 3)
    error("Usage: smoothMS1(dataRowVector, degree, m)");
  endif
  if (columns(data) < 2 || rows(data) != 1)
    error("Less than two data points or not a row vector");
  endif
  kernel = kernelMS1(deg, m);
  fitWeights = edgeWeights1(deg, m);
  extData = extendData(data, m, fitWeights);
  smoothedExtData = conv(extData, kernel, "same");
  smoothedData = smoothedExtData(m+1 : end-m);
endfunction

# Correction coeffficients for a flat passband of the MS kernel
function coeffs = corrCoeffsMS(deg)
  switch (deg)
    case (2)
      coeffs = [];
    case (4)
      coeffs = [];
    case (6)
      coeffs = [0.001717576, 0.02437382, 1.64375];
    case(8)
      coeffs = [0.0043993373, 0.088211164, 2.359375;
                0.006146815, 0.024715371, 3.6359375];
    case (10)
      coeffs = [0.0011840032, 0.04219344, 2.746875;
                0.0036718843, 0.12780383, 2.7703125];
    otherwise error("Invalid deg");
  endswitch
endfunction

# Correction coeffficients for a flat passband of the MS1 kernel
function coeffs = corrCoeffsMS1(deg)
  switch (deg)
    case (2)
      coeffs = [];
    case (4)
      coeffs = [0.021944195, 0.050284006, 0.765625];
    case (6)
      coeffs = [0.001897730, 0.00847681, 1.2625;
                0.023064667, 0.13047926, 1.2265625];
    case(8)
      coeffs = [0.006590300, 0.05792946, 1.915625;
                0.002323448, 0.01029885, 2.2726562;
                0.021046653, 0.16646601, 1.98125];
    case (10)
      coeffs = [9.749618E-4, 0.00207429, 3.74375;
                0.008975366, 0.09902466, 2.707812;
                0.002419541, 0.01006486, 3.296875;
                0.019185117, 0.18953617, 2.784961];
    otherwise error("Invalid deg");
  endswitch
endfunction

# Calculates the MS convolution kernel
function kernel = kernelMS(deg, m)
  coeffs = corrCoeffsMS(deg);
  kappa = []; #correction coefficients for the kernel
  for abcd = coeffs'
    kappa(end+1) = abcd(1) + abcd(2)/cube(abcd(3)-m);
  endfor
  if (rem(deg/2, 2) == 1) #degree 6, 10
    nuMinus2 = -1;
  else
    nuMinus2 = 0;
  endif
  kernel(m+1) = windowMS(0, 4); #center element
  for i = 1 : m
    x = i/(m+1);
    w = windowMS(x, 4);
    a = sin((0.5*deg+2)*pi*x)/((0.5*deg+2)*pi*x);
    for j = 1 : length(kappa)
      a = a + kappa(j)*x*sin((2*j+nuMinus2)*pi*x);
    endfor
    a = a*w;
    kernel(m+1-i) = a;
    kernel(m+1+i) = a;
  endfor
  norm = sum(kernel);
  kernel = kernel./norm;
endfunction

# Calculates the MS1 convolution kernel
function kernel = kernelMS1(deg, m)
  coeffs = corrCoeffsMS1(deg);
  kappa = [];
  for abcd = coeffs'
    kappa(end+1) = abcd(1) + abcd(2)/cube(abcd(3)-m);
  endfor
  kernel(m+1) = windowMS(0, 2); #center element
  for i = 1 : m
    x = i/(m+1);
    w = windowMS(x, 2);
    a = sin((0.5*deg+1)*pi*x)/((0.5*deg+1)*pi*x);
    for j = 1 : length(kappa)
      a = a + kappa(j)*x*sin(j*pi*x);
    endfor
    a = a*w;
    kernel(m+1-i) = a;
    kernel(m+1+i) = a;
  endfor
  norm = sum(kernel);
  kernel = kernel./norm;
endfunction


# Gaussian-like window function for the MS and MS1 kernels.
# The function reaches 0 at x=+1 and x=-1 (where the kernel ends);
# at these points also the 1st derivative is very close to zero.
function w = windowMS(x, alpha)
  w = exp(-alpha.*x.*x) + exp(-alpha.*(x+2).*(x+2)) + exp(-alpha.*(x-2).*(x-2)) ...
     - (2*exp(-alpha)+exp(-9*alpha));
endfunction

# Hann-square weights for linear fit at the edges, for MS smoothing.
function w = edgeWeights(deg, m)
  beta = 0.70 + 0.14*exp(-0.6*(deg-4));
  fitLengthD = ((m+1)*beta)/(1.5+0.5*deg);
  fitLength = floor(fitLengthD);
  for i = 1 : fitLength+1
    cosine = cos(pi/2*(i-1)/fitLengthD);
    w(i) = cosine*cosine;
  endfor
endfunction

# Hann-square weights for linear fit at the edges, for MS1 smoothing.
function w = edgeWeights1(deg, m)
  beta = 0.65 + 0.35*exp(-0.55*(deg-4));
  fitLengthD = ((m+1)*beta)/(1+0.5*deg);
  fitLength = floor(fitLengthD);
  for i = 1 : fitLength+1
    cosine = cos(pi/2*(i-1)/fitLengthD);
    w(i) = cosine*cosine;
  endfor
endfunction

# Extends the data by weighted linear extrapolation, for smoothing to the ends
function extData = extendData(data, m, fitWeights)
  datLength = length(data);
  fitLength = length(fitWeights);
  fitX = 1:fitLength;
  fitY = data(1:fitLength);
  [offset, slope] = fitWeighted(fitX, fitY, fitWeights);
  #fitBasis = [ones(1, fitLength); 1:fitLength];
  #[params] = LinearRegression (fitBasis', fitY', fitWeights');
  extData(1:m) = offset + (-m+1:0) * slope;
  extData(m+1 : datLength+m) = data;
  fitY = flip(data(datLength-fitLength+1 : datLength));
  [offset, slope] = fitWeighted(fitX, fitY, fitWeights);
  #[params] = LinearRegression (fitBasis', fitY', fitWeights');
  #extData(datLength+m+1 : datLength+2*m) = [ones(1, m); 0:-1:-m+1]' * params;
  extData(datLength+m+1 : datLength+2*m) = offset + (0:-1:-m+1) * slope;
endfunction

# Weighted linear fit of the data.
# All inputs must be row vectors of equal length.
function [offset, slope] = fitWeighted(xData, yData, weights)
  sumWeights = sum(weights);
  sumX  = sum(xData.*weights);
  sumY  = sum(yData.*weights);
  sumX2 = sum(xData.*xData.*weights);
  sumXY = sum(xData.*yData.*weights);
  disp("sumX2")
  sumX2
  varX2 = sumX2*sumWeights - sumX*sumX;
  if (varX2 == 0)
    slope = 0;
  else
    slope = (sumXY*sumWeights - sumX*sumY)/varX2;
  endif
  offset = (sumY-slope*sumX)/sumWeights;
endfunction

function xcube = cube(x)
  xcube = x*x*x;
endfunction

# The following code is for testing only.
# It should be removed when using the filter for user data.
# The output should be:
#   0.15835885  0.11657466 -0.09224721  0.03165689 -0.05481473
#  -0.05436219  0.51054827 -0.59067866 -1.21928695  5.28610520
#  10.46161952  6.82674246  2.49236743  1.04220381  0.03264660
deg = 6; # degree
m = 7;   # kernel halfwidth
data = [0, 1, -2, 3, -4, 5, -6, 7, -8, 9, 10, 6, 3, 1, 0];
printf("smoothMS of test data:");
out = smoothMS(data, deg, m);
printf("%10.8f %10.8f %10.8f %10.8f %10.8f\n", out);

