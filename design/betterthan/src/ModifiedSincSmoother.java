/* 
 * ModifiedSincSmoother
 */

import java.util.Arrays;

/**
 *  A Java implementation of smoothing by a modified sinc
 *  kernel (MS or MS1), as described in M. Schmid and U. Diebold,
 *  'Why and how Savitzky-Golay filters should be replaced'
 *  The term 'degree' is defined in analogy to Savitzky-Golay (SG) filters;
 *  the current MS filters have a similar frequency response as SG filters
 *  of the same degree (2, 4, ... 10).
 *  <h3>
 *  Copyright notice
 *  </h3>
 *  This code is licensed under GNU General Public License (GPLv3) and
 *  Creative Commons Attribution-ShareAlike 4.0 (CC-BY-SA 4.0).
 *  When using and/or modifying this program for scientific work
 *  and the paper on it has been published, please cite the paper:
 *  M. Schmid, D. Rath and U. Diebold,
 * 'Why and how Savitzky-Golay filters should be replaced',
 *  ACS Measurement Science Au, 2022
 *  <p>
 *  Author: Michael Schmid, IAP/TU Wien, 2021.
 *          https://www.iap.tuwien.ac.at/www/surface/group/schmid
 */
 
public class ModifiedSincSmoother {
    /** This implementation is for a maximum degree of 10 */
    public final static int MAX_DEGREE = 10;
    /** Coefficients for the MS filters, for obtaining a flat passband.
     *  The innermost arrays contain a, b, c for the fit
     *  kappa = a + b/(c - m) */
    final static double[][][] CORRECTION_DATA = new double[][][] {
            null, //not defined for degree 0
            null, //no correction required for degree 2
            null, //no correction required for degree 4
            //data for 6th degree coefficient for flat passband
            {{0.001717576, 0.02437382, 1.64375}},
            //data for 8th degree coefficient for flat passband
            {{0.0043993373, 0.088211164, 2.359375},
             {0.006146815, 0.024715371, 3.6359375}},
            //data for 10th degree coefficient for flat passband
            {{0.0011840032, 0.04219344, 2.746875},
             {0.0036718843, 0.12780383, 2.7703125}}
    };
    /** Coefficients for the MS1 filters, for obtaining a flat passband.
     *  The innermost arrays contain a, b, c for the fit
     *  kappa = a + b/(c - m) */
    final static double[][][] CORRECTION_DATA1 = new double[][][] {
            null, //not defined for degree 0
            null, //no correction required for degree 2
            //data for 4th degree coefficient for flat passband, a, b, c
            {{0.021944195, 0.050284006, 0.765625}},
            //data for 6th degree coefficient for flat passband
            {{0.0018977303, 0.008476806, 1.2625},
             {0.023064667, 0.13047926, 1.2265625}},
            //data for 8th degree coefficient for flat passband
            {{0.0065903002, 0.057929456, 1.915625},
             {0.0023234477, 0.010298849, 2.2726562},
             {0.021046653, 0.16646601, 1.98125}},
            //data for 10th degree coefficient for flat passband
            {{9.749618E-4, 0.0020742896, 3.74375},
             {0.008975366, 0.09902466, 2.7078125},
             {0.0024195414, 0.010064855, 3.296875},
             {0.019185117, 0.18953617, 2.784961}},
    };
    /** Whether MS1 (not MS) filtering should be used */
    private boolean isMS1;
    /** The degree (2, 4, ... 10) */
    private int degree;
    /** The kernel for filtering */
    private double[] kernel;
    /** The weights for linear fitting for extending the data at the boundaries */
    private double[] fitWeights;

    /** This constructor is only for testing the filter.  It can be removed.
     *  The result should be: <br>
     *  [0.1583588453161306,    0.11657466389491726, -0.09224721042380793, 0.031656885544917315,
     *  -0.054814729808335835, -0.054362188355910813, 0.5105482655952578, -0.5906786605713916,
     *  -1.2192869459451745,    5.286105202110525,   10.461619519603234,   6.82674246410578,
     *   2.4923674303784833,    1.0422038091960153,   0.032646599192913656]

     */
    public ModifiedSincSmoother() {
        boolean isMS1 = false;
        int degree = 6;
        int m = 7;
        kernel = makeKernel(isMS1, degree, m);
        fitWeights = makeFitWeights(isMS1, degree, m);
        double[] data = new double[] //arbitrary test data
                {0, 1, -2, 3, -4, 5, -6, 7, -8, 9, 10, 6, 3, 1, 0};
        double[] out = smooth(data, null);
        System.out.println("Filtered data:");
        System.out.println(Arrays.toString(out));
    }

    /**
     * Creates a ModifiedSincSmoother with given degree and given kernel size.
     * This constructor is useful for repeated smoothing operations with
     * the same parameter; then the non-statioc <code>smooth(double[], double[])</code>
     * can be used without calculating the kernel and boundary fit weights each
     * time.
     * Otherwise the static <code>smooth(double[], int, int)</code>
     * method is more convenient.
     * @param isMS1 if true, uses the MS1 variant, which has a smaller kernel size,
     *          at the cost of reduced stopband suppression and more gradual cutoff
     *          for degree=2. Otherwise, standard MS kernels are used.
     * @param degree Degree of the filter, must be 2, 4, ... MAX_DEGREE.
     *          As for Savitzky-Golay filters, higher degree results in
     *          a sharper cutoff in the frequency domain.
     * @param m The half-width of the kernel, must be larger than degree/2.
     *          The kernel size is <code>2*m + 1</code>.
     *          The <code>m</code> parameter can be determined with bandwidthToM. 
     */
    public ModifiedSincSmoother(boolean isMS1, int degree, int m) {
        this.isMS1 = isMS1;
        this.degree = degree;
        if (degree < 2 || degree > MAX_DEGREE || (degree&0x1)!=0)
            throw new IllegalArgumentException("Invalid degree "+degree+"; only 2, 4, ... "+MAX_DEGREE+" supported");
        int mMin = isMS1 ? degree/2+1 : degree/2+2;
        if (m < mMin)  //kernel not wide enough for the wiggles of the sinc function
            throw new IllegalArgumentException("Invalid kernel half-width "+m+"; must be >= "+mMin);
        kernel = makeKernel(isMS1, degree, m);
        fitWeights = makeFitWeights(isMS1, degree, m);
    }

    /**
     * Smooths the data with the parameters passed with the constructor,
     * except for the near-end points.
     * @param data The input data.
     * @param out  The output array; may be null. If <code>out</code> is
     *          supplied, has the correct size, and is not the input array,
     *          it is used for the output.
     * @return  The smoothed data. If <code>out</code> is non-null and has
     *          the correct size, this is the <code>out</code> array.
     *          Values within <code>m</code> points from boundaries, where
     *          the convolution is undefined remain 0 (or retain the
     *          previous value, if the supplied <code>out</code> array
     *          is used).
     */
    public double[] smoothExceptBoundaries(double[] data, double[] out) {
        if (out == null || out.length != data.length || out == data)
            out = new double[data.length];
        int radius = kernel.length - 1; //how many additional points we need
        for (int i=radius; i<data.length-radius; i++) {
            double sum = kernel[0]*data[i];
            for (int j=1; j<kernel.length; j++) {
                sum += kernel[j]*(data[i-j]+data[i+j]);
            }
            out[i] = sum;
        }
        return out;
    }

    /**
     * Smooths the data with the parameters passed with the constructor,
     * including the near-boundary points. The near-boundary points are
     * handled by weighted linear extrapolation of the data before smoothing.
     * @param data The input data.
     * @param out  The output array; may be null. If <code>out</code> is
     *          supplied and has the correct size, it is used for the output.
     * @return  The smoothed data. If <code>out</code> is non-null and has
     *          the correct size, this is the <code>out</code> array.
     */
    public double[] smooth(double[] data, double[] out) {
        int radius = kernel.length - 1;
        double[] extendedData = extendData(data, radius, degree);
        double[] extendedSmoothed = smoothExceptBoundaries(extendedData, null);
        if (out == null || out.length != data.length)
            out = new double[data.length];
        System.arraycopy(extendedSmoothed, radius, out, 0, data.length);

        return out;
    }

    /**
     * Smooths the data and with the given parameters.
     * When smoothing multiple data sets with the same parameters,
     * using the constructor and then smooth(double[], double[])
     * will be more efficient.
     * @param data   The input data.
     * @param isMS1 if true, uses the MS1 variant, which has a smaller kernel size,
     *          at the cost of reduced stopband suppression and more gradual cutoff
     *          for degree=2. Otherwise, standard MS kernels are used.
     * @param degree Degree of the filter, must be 2, 4, 6, ... MAX_DEGREE.
     *          As for Savitzky-Golay filters, higher degree results in
     *          a sharper cutoff in the frequency domain.
     * @param m The half-width of the kernel. The kernel size is
     *          <code>2*m + 1</code>. The <code>m</code> parameter can be
     *          determined with bandwidthToM.
     * @return The smoothed data. Values within <code>m</code> points from
     *          boundaries, where the convolution is undefined, are set to 0.
     */
    public static double[] smooth(double[] data, boolean isMS1, int degree, int m) {
        ModifiedSincSmoother smoother = new ModifiedSincSmoother(isMS1, degree, m);
        return smoother.smooth(data, null);
    }

    /**
     * Smooths the data in a way comparable to a traditional Savitzky-Golay
     * filter with the given parameters <code>degree</code> and <code>m</code>.
     * @param data The input data.
     * @param isMS1 if true, uses the MS1 variant, which has a smaller kernel size,
     *          at the cost of reduced stopband suppression and more gradual cutoff
     *          for degree=2. Otherwise, standard MS kernels are used.
     * @param degree Degree of the Savitzky-Golay filter that should be replaced,
     *          must be 2, 4, 6, ... MAX_DEGREE.
     * @param m The half-width of a Savitzky-Golay filter that should be replaced.
     * @return  The smoothed data.
     */
    public static double[] smoothLikeSavitzkyGolay(double[] data, boolean isMS1, int degree, int m) {
        double bandwidth = savitzkyGolayBandwidth(degree, m);
        int mMS = bandwidthToM(isMS1, degree, bandwidth);
        return smooth(data, isMS1, degree, mMS);
    }

    /**
     * Calculates the kernel halfwidth m that comes closest to the desired
     * band width, i.e., the frequency where the response decreases to
     * -3 dB, i.e., 1/sqrt(2).
     * @param isMS1 if true, calculates for the MS1 variant, which has a smaller kernel size,
     *          at the cost of reduced stopband suppression and more gradual cutoff
     *          for degree=2. Otherwise, standard MS kernels are used.
     * @param degree Degree of the filter, must be 2, 4, 6, ... MAX_DEGREE.
     *         As for Savitzky-Golay filters, higher degree results in
     *         a sharper cutoff in the frequency domain.
     * @param bandwidth The desired band width, with respect to the sampling frequency.
     *         The value of <code>bandwidth</code> must be less than 0.5
     *         (the Nyquist frequency).
     * @return The kernel halfwidth m.
     */
    public static int bandwidthToM(boolean isMS1, int degree, double bandwidth) {
        if (bandwidth <= 0 || bandwidth >= 0.5)
            throw new IllegalArgumentException("Invalid bandwidth value: "+bandwidth);
        double radius = isMS1 ?
                (0.27037 + 0.24920*degree)/bandwidth - 1.0 :
                (0.74548 + 0.24943*degree)/bandwidth - 1.0;
        return (int)Math.round(radius);
    }

    /**
     * Calculates the kernel halfwidth m best suited for obtaining a given noise gain.
     * @param isMS1 if true, calculates for the MS1 variant, which has a smaller kernel size,
     *          at the cost of reduced stopband suppression and more gradual cutoff
     *          for degree=2. Otherwise, standard MS kernels are used.
     * @param degree    The degree n of the kernel
     * @param noiseGain The factor by which white noise should be suppressed.
     * @return The kernel halfwidth m required.
     */
    public static int noiseGainToM(boolean isMS1, int degree, double noiseGain) {
        double invNoiseGainSqr = 1./(noiseGain*noiseGain);
        double exponent = -2.5-0.8*degree;
        double m = isMS1 ?
                -1 + invNoiseGainSqr*(0.543 + 0.4974*degree) +
                     0.47*Math.pow(invNoiseGainSqr, exponent) :
                -1 + invNoiseGainSqr*(1.494 + 0.4965*degree) +
                     0.52*Math.pow(invNoiseGainSqr, exponent);
        return (int)Math.round(m);
    }

    /**
     * Creates a kernel and returns it.
     * @param isMS1  if true, calculates the kernel for the MS1 variant.
     *          Otherwise, standard MS kernels are used.
     * @param degree The degree n of the kernel
     * @param m The half-width of the SG kernel. The kernel size of the
     *          filter is <code>2*m + 1</code>.
     */
    static double[] makeKernel(boolean isMS1, int degree, int m) {
        double[] coeffs = getCoefficients(isMS1, degree, m);
        return  makeKernel(isMS1, degree, m, coeffs);
    }

    /**
     * Creates a kernel and returns it.
     * @param isMS1  If true, calculates the kernel for the MS1 variant.
     *          Otherwise, standard MS kernels are used.
     * @param degree The degree n of the kernel, i.e. the polynomial degree of a Savitzky-Golay filter
     *          with similar passband, must be 2, 4, ... MAX_DEGREE.
     * @param m The half-width of the kernel (the resulting kernel
     *          has <code>2*m+1</code> elements).
     * @param coeffs Correction parameters for a flatter passband, or
     *          null for no correction (used for degree 2).
     * @return  One side of the kernel, starting with the element at the
     *          center. Since the kernel is symmetric, only one side with
     *          <code>m+1</code> elements is needed.
     */
    static double[] makeKernel(boolean isMS1, int degree, int m, double[] coeffs) {
        if (degree<2 || degree > MAX_DEGREE || (degree & 0x01)!= 0)
            throw new IllegalArgumentException("Unsupported degree "+degree);
        double[] kernel = new double[m+1];
        int nCoeffs = coeffs == null ? 0 : coeffs.length;
        double sum = 0;
        for (int i=0; i<=m; i++) {
            double x = i*(1./(m+1)); //0 at center, 1 at zero
            double sincArg = Math.PI*0.5*(isMS1 ? degree+2 : degree+4)*x;
            double k = i==0 ? 1 : Math.sin(sincArg)/sincArg;
            for (int j=0; j<nCoeffs; j++) {
                if (isMS1)
                    k += coeffs[j] * x * Math.sin((j+1)*Math.PI*x); //shorter kernel version, needs more correction terms
                else {
                    int nu = ((degree/2)&0x1) == 0 ? 2 : 1; //start at 1 for degree 6, 10; at 2 for degree 8
                    k += coeffs[j] * x * Math.sin((2*j+nu)*Math.PI*x);
                }
            }
            double decay = isMS1 ? 2 : 4;  //decay alpha =2: 13.5% at end without correction, 2sqrt2 sigma
            k *= Math.exp(-x*x*decay) + Math.exp(-(x-2)*(x-2)*decay) +
                    Math.exp(-(x+2)*(x+2)*decay) - 2*Math.exp(-decay) - Math.exp(-9*decay);
            kernel[i] = k;
            sum += k;
            if (i > 0) sum += k;    //off-center kernel elements appear twice
        }
        for (int i=0; i<=m; i++)
            kernel[i] *= 1./sum;    //normalize the kernel to sum = 1
        return kernel;
    }

    /**
     * Returns the correction coefficients for a Sinc*Gaussian kernel
     * to flatten the passband.
     * @param isMS1  If true, returns the coefficients for the MS1 variant.
     *          Otherwise, coefficients for the standard MS kernels returned.
     * @param degree The polynomial degree of a Savitzky-Golay filter
     *          with similar passband, must be 2, 4, ... MAX_DEGREE.
     * @param m The half-width of the kernel.
     * @return  Coefficients z for the x*sin((j+1)*PI*x) terms, or null
     *          if no correction is required.
     */
    static double[] getCoefficients(boolean isMS1, int degree, int m) {
        double[][][] correctionData = isMS1 ? CORRECTION_DATA1 : CORRECTION_DATA;
        double[][] corrForDeg = correctionData[degree/2];
        if (corrForDeg == null) return null;
        double[] coeffs = new double[corrForDeg.length];
        for (int i=0; i<corrForDeg.length; i++) {
            double[] abc = corrForDeg[i];   // a...c of equation a + b/(c - m)^3
            double cm = abc[2] - m;         // c - m
            coeffs[i] = abc[0] + abc[1]/(cm*cm*cm);
        }
        return coeffs;
    }

    /**
     * Returns the weights for the linear fit used for linear extrapolation
     * at the end. The weight function is a Hann (cos^2) function. For beta=1
     * (the beta value for n=4), it decays to zero at the position of the
     * first zero of the sinc function in the kernel. Larger beta values lead
     * to stronger noise suppression near the edges, but the smoothed curve
     * does not follow the input as well as for lower beta (for high degrees,
     * also leading to more ringing near the boundaries).
     * @param isMS1  if true, returns weights for the MS1 variant.
     *          Otherwise, returns weights for the standard MS kernels.
     * @param degree The polynomial degree of a Savitzky-Golay filter
     *          with similar passband, must be 2, 4, ... MAX_DEGREE.
     * @param m The half-width of the kernel (the resulting kernel
     *          has 2*m+1 elements).
     * @return  The fit weights, with array element [0] corresponding
     *          to the data value at the very end.
     */
    static double[] makeFitWeights(boolean isMS1, int degree, int m) {
        double firstZero = isMS1 ?      //the first zero of the sinc function
            (m+1)/(1+0.5*degree) :
            (m+1)/(1.5+0.5*degree);
        double beta = isMS1 ?
                0.65 + 0.35*Math.exp(-0.55*(degree-4)) :
                0.70 + 0.14*Math.exp(-0.60*(degree-4));
        int fitLength = (int)Math.ceil(firstZero*beta);
        double[] weights = new double[fitLength];
        for (int p=0; p<fitLength; p++)
            weights[p] = sqr(Math.cos(0.5*Math.PI/(firstZero*beta)*p));
        return weights;
    }

    /**
     * Calculates the bandwidth of a traditional Savitzky-Golay (SG) filter.
     * @param degree The degree of the polynomial fit used in the SG filter.
     * @param m The half-width of the SG kernel. The kernel size of the SG
     *         filter, i.e. the number of points for fitting the polynomial
     *         is <code>2*m + 1</code>.
     * @return The -3 dB-bandwidth of the SG filter, i.e. the frequency where the
     *         response is 1/sqrt(2). The sampling frequency is defined as f = 1.
     *         For <code>degree</code> up to 10, the accuracy is typically much
     *         better than 1%; higher errors occur only for the lowest
     *         <code>m</code> values where the SG filter is defined
     *         (worst case: 4% error at <code>degree = 10, m = 6</code>).     
     */
    public static double savitzkyGolayBandwidth(int degree, int m) {
        return 1./(6.352*(m+0.5)/(degree+1.379) - (0.513+0.316*degree)/(m+0.5));
    }

    /**
     * Extends the data by a weighted fit to a linear function (linear regression).
     * @param data The input data
     * @param m The halfwidth of the kernel. The number of data points
     *         contributing to one output value is <code>2*m + 1</code>.
     * @param degree The polynomial degree of a Savitzky-Golay filter
     *         with similar passband, must be 2, 4, ... MAX_DEGREE.
     * @return The input data with extrapolated values appended at both ends.
     *         At each end, <code>m</code> extrapolated points are appended.
     */
    double[] extendData(double[] data, int m, int degree) {
        double[] extendedData = new double[data.length+2*m];
        System.arraycopy(data, 0, extendedData, m, data.length);
        LinearRegression linreg = new LinearRegression();
        // linear fit of first points and extrapolate
        int fitLength = (int)Math.min(fitWeights.length, data.length);
        for (int p=0; p<fitLength; p++)
            linreg.addPointW(p, data[p], fitWeights[p]);
        double offset = linreg.getOffset();
        double slope  = linreg.getSlope();
        for (int p=-1; p>=-m; p--)
            extendedData[m+p] = offset + slope*p;
        // linear fit of last points and extrapolate
        linreg.clear();
        for (int p=0; p<fitLength; p++)
            linreg.addPointW(p, data[data.length-1-p], fitWeights[p]);
        offset = linreg.getOffset();
        slope  = linreg.getSlope();
        for (int p=-1; p>=-m; p--)
            extendedData[data.length+m-1-p] = offset + slope*p;
        return extendedData;
    }

    /** Returns the square of a number */
    static double sqr(double x) {return x*x;}

}

/** Linear regression is used for extrapolating the data at the boundaries */
class LinearRegression {
    /** sum of weights (number of points if all weights are one */
    protected double sumWeights = 0;
    /** sum of all x values */
    protected double sumX = 0;
    /** sum of all y values */
    protected double sumY = 0;
    /** sum of all x*y products */
    protected double sumXY = 0;
    /** sum of all squares of x */
    protected double sumX2 = 0;
    /** sum of all squares of y */
    protected double sumY2 = 0;
    /** result of the regression: offset */
    protected double offset = Double.NaN;
    /** result of the regression: slope */
    protected double slope = Double.NaN;
    /** whether the results (offset, slope) have been calculated already */
    protected boolean calculated = false;

    /** Clear the linefit */
    public void clear() {
        sumWeights = 0;
        sumX = 0;
        sumY = 0;
        sumXY = 0;
        sumX2 = 0;
        sumY2 = 0;
        calculated = false;
    }

    /** Add a point x,y with weight */
    public void addPointW(double x, double y, double weight) {
        sumWeights += weight;
        sumX += weight*x;
        sumY += weight*y;
        sumXY += weight*x*y;
        sumX2 += weight*x*x;
        sumY2 += weight*y*y;
        calculated = false;
    }

    /** Do the actual regression calculation */
    public void calculate() {
        double stdX2TimesN = sumX2-sumX*sumX*(1/sumWeights);
        double stdY2TimesN = sumY2-sumY*sumY*(1/sumWeights);
        if (sumWeights>0) {
            slope=(sumXY-sumX*sumY*(1/sumWeights))/stdX2TimesN;
            if (Double.isNaN(slope)) slope=0;       //slope 0 if only one x value
        } else
            slope = Double.NaN;
        offset = (sumY-slope*sumX)/sumWeights;
        calculated = true;
    }

    /** Returns the offset (intersection on y axis) of the fit */
    public double getOffset() {
        if (!calculated) calculate();
        return offset;
    }

    /** Returns the slope of the line of the fit */
    public double getSlope() {
        if (!calculated) calculate();
        return slope;
    }
}
