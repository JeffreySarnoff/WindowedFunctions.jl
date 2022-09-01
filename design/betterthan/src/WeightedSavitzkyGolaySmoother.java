/* 
 * WeightedSavitzkyGolaySmoother
 */


import java.util.Arrays;

/**
 *  A simple Java implementation of Savitzky-Golay smoothing with
 *  weights for a better suppression of the stopband than traditional
 *  Savitzky-Golay (SG). It can also do traditional SG smoothing with
 *  weights=NONE.
 * 
 *  <h3>
 *  Copyright notice
 *  </h3>
 *  This code is licensed under GNU General Public License (GPLv3).
 *  When using and/or modifying this program for scientific work
 *  and the paper on it has been published, please cite the paper:
 *  M. Schmid, D. Rath and U. Diebold,
 * 'Why and how Savitzky-Golay filters should be replaced',
 *  ACS Measurement Science Au, 2022
 *  <p>
 *  Author: Michael Schmid, IAP/TU Wien, Copyright (C) 2021.
 *          https://www.iap.tuwien.ac.at/www/surface/group/schmid
 */
 
public class WeightedSavitzkyGolaySmoother {
    /** Weight type 'none', this results in traditional SG smoothing */
    public final static int NONE=0;
    /** Weight type for a modified Gaussian with alpha=2, as described in the paper by Schmid and Diebold */
    public final static int GAUSS2=1;
    /** Weight type for a Hann window function (also known as raised cosine or cosine-square) */
    public final static int HANN=2;
    /** Weight type for a Hann-square window function (also known as cos^4) */
    public final static int HANNSQR=3;
    /** Weight type for a Hann-cube window function (also known as cos^6) */
    public final static int HANNCUBE=4;
    /** Coefficients a,b,c for x-scale of near-end kernel functions of the SGW filters,
     *  for equation scale s = 1-a/(1+b*Math.pow(x,c)) */
    final static double[][] weightScaleCoeffs = new double [][] {
        {1, 1, -1},                     //weightType=NONE
        {0.68096, 0.36358, -3.68528},   //GAUSS2
        {0.67574, 0.35440, -3.61580},   //HANN
        {0.63944, 0.28417, -5.508},     //HANNSQR
        {0.62303, 0.25310, -7.07317}    //HANNCUBE
    };
    /** The kernels for near-boundary and interior points. */
    private double[][] kernels;

    /**
     * Creates a WeightedSavitzkyGolaySmoother with a given weight
     * function, given degree and kernel halfwidth. This
     * constructor is useful for repeated smoothing operations with
     * the same parameters and data sets of the same length.
     * Otherwise the static <code>smooth(double[], int, int, int)</code>
     * method is more convenient.
     * @param weightType 
     * @param degree Degree ofthe polynomial fit.
     * @param m halfwidth of the kernel.
     */
    public WeightedSavitzkyGolaySmoother(int weightType, int degree, int m) {
        kernels = makeKernels(weightType, degree, m);
    }

    /**
    /** This constructor is only for testing the filter.  It can be removed.
     *  The edge kernel, kernels[0], should be: <br>
     *   [0.9860734984300393,    0.056918568996510654, -0.06931653363045043,   0.001217044253974356,
     *    0.033852366327283966,  0.012208144151913635, -0.013853157267840751, -0.01569839895394231,
     *   -0.0014813956478430153, 0.008387115758517773,  0.005938018439190397, -0.0011816807905541734,
     *   -0.00341113701958563,  -6.743302754188831E-4,  0.0010218772281337806] <br>
     *  The filtered data should be:
     *   [0.2267817407230225,  0.3803379776275339, -0.2542196669759636,  -0.16144537772877116,
     *    0.16108284817615762, 0.4525943769926024, -0.41288045376351673, -1.0937687611036997,
     *    0.6198930998271857,  4.862721666447915,   8.535294804032034,    7.223205439511203,
     *    3.3820361761910283, -0.14330976836859274, 0.3352794400491729]
     */
    public WeightedSavitzkyGolaySmoother() {
        double[] data = new double[] //arbitrary test data
                {0, 1, -2, 3, -4, 5, -6, 7, -8, 9, 10, 6, 3, 1, 0};
        int weightType = HANNSQR;
        int degree = 6;
        int m = 7;
        kernels = makeKernels(weightType, degree, m);
        double[] out = smooth(data, null);
        System.out.println("kernels[0]:");
        System.out.println(Arrays.toString(kernels[0]));
        System.out.println("Filtered data:");
        System.out.println(Arrays.toString(out));
    }

    /**
     * Smooths the data with the parameters passed with the constructor.
     * This function is implemented only for data arrays that have least 2m+1 elements,
     * where m is the kernel halfwidth.
     * @param data The input data.
     * @param out  The output array; may be null. If <code>out</code> is supplied
     *          and has the correct size, it is used for the output. <code>out</code>
     *          may be null or the input array <code>data</code>; in the latter case
     *          the input is overwritten.
     * @return The smoothed data. If <code>out</code> is non-null, has the correct
     *          size, and is not the input array, this is the <code>out</code> array.
     */
    public double[] smooth(double[] data, double[] out) {
        out = convolve(data, out, kernels);
        return out;
    }

    /**
     * Smooths the data with the parameters passed with a given weight
     * function, given degree and kernel halfwidth m.
     * This function is implemented only for data arrays that have least 2m+1 elements.
     * @param data The input data.
     * @param out  The output array; may be null. If <code>out</code> is supplied,
     *          has the correct size and is not the input, it is used for the output.
     * @param weightType Type of the Weight function, NONE for traditional SG, HANNSQR for
     *          the filters described in the paper
     * @param degree Degree of the polynomial fit.
     * @param m Halfwidth of the kernel.
     * @return The smoothed data. If <code>out</code> is non-null, has the correct
     *          size, and is not the input array, this is the <code>out</code> array.
     */
    public static double[] smooth(double[] data, double[] out, int weightType, int degree, int m) {
        WeightedSavitzkyGolaySmoother smoother = new WeightedSavitzkyGolaySmoother(weightType, degree, m);
        return smoother.smooth(data, out);
    }

    /**
     * Smooths the data in a way comparable to a traditional Savitzky-Golay
     * filter with the given parameters <code>degree</code> and <code>m</code>,
     * but with Hann-square weights, resulting substantially better noise rejection.
     * This function is implemented only for data arrays that have least as many
     * elements as the SGW kernel. This is more than 2m+1, but never more than 4m+1.
     * @param data The input data.
     * @param degree The degree of the polynomial fit used in the SG(W) filter.
     * @param m The half-width of the SG kernel. The kernel size of the SG
     *        filter, i.e. the number of points for fitting the polynomial
     *        is <code>2*m + 1</code>.
     * @return The smoothed data.
     */
    public static double[] smoothLikeSG(double[] data, int degree, int m) {
        double bandwidth = savitzkyGolayBandwidth(degree, m);
        int mSGW = bandwidthToHalfwidth(degree, bandwidth);
        return smooth(data, null, HANNSQR, degree, mSGW);
    }

    /**
     * Calculates the kernel halfwidth m for a given band width, i.e.,
     * the frequency where the response decreases to -3 dB, corresponding to 1/sqrt(2),
     * for a SGW filter with HANNSQR weights.
     * @param degree    The degree of the polynomial fit used in the SGW filter.
     * @param bandwidth The desired band width, with respect to the sampling frequency.
     *        The value of <code>bandwidth</code> must be less than 0.5
     *        (the Nyquist frequency).
     * @return The kernel halfwidth m for this band width.
     */
    public static int bandwidthToHalfwidth(int degree, double bandwidth) {
        if (bandwidth <= 0 || bandwidth >= 0.5)
            throw new IllegalArgumentException("Invalid bandwidth value: "+bandwidth);
        int m = (int)Math.round((0.5090025+degree*(0.1922392-degree*0.001484498))/bandwidth - 1.0);
        return m;
    }

    /**
     * Calculates the bandwidth of a traditional Savitzky-Golay (SG) filter.
     * @param degree The degree of the polynomial fit used in the SG filter.
     * @param m The half-width of the SG kernel. The kernel size of the SG
     *        filter, i.e. the number of points for fitting the polynomial
     *        is <code>2*m + 1</code>.
     * @return The -3 dB-bandwidth of the SG filter, i.e. the frequency where the
     *        response is 1/sqrt(2). The sampling frequency is defined as f = 1.
     *        For <code>degree</code> up to 10, the accuracy is typically much
     *        better than 1%; higher errors occur only for the lowest
     *        <code>m</code> values where the SG filter is defined
     *        (worst case: 4% error at <code>degree = 10, m = 6</code>).     
     */
    public static double savitzkyGolayBandwidth(int degree, int m) {
        return 1./(6.352*(m+0.5)/(m+1.379) - (0.513+0.316*m)/(m+0.5));
    }


    /** Convolves the data, for each point using the appropriate kernel for interior
     *  or near-boundary points from the kernels supplied.
     *  This function is implemented only for data arrays that have least 2m+1 elements.
     *  The output array may be supplied; if null or unsuitable a new output array is created. */
    static double[] convolve(double[] data, double[] out, double[][] kernels) {
        int m = kernels[kernels.length-1].length/2;
        if (data.length < 2*m + 1)
            throw new RuntimeException("Data array too short; min length: "+(2*m + 1));
        if (out == null || out.length != data.length || out == data)
            out = new double[data.length];
        for (int i=0; i<data.length-m; i++) {  //left near-boundary and interior points
            double[] kernel = kernels[Math.min(i, kernels.length-1)];
            double sum=0;
            for (int j=0; j<kernel.length; j++)
                sum += kernel[j]*data[Math.max(i-m,0)+j];
            out[i] = sum;
        }
        for (int i=data.length-m; i<data.length; i++) { //near boundary points at the right
            double[] kernel = kernels[data.length-1-i];
            double sum=0;
            for (int j=0; j<kernel.length; j++)
                sum += kernel[j]*data[data.length-1-j];
            out[i] = sum;
        }
        return out;
    }

    /** Creates Savitzky-Golay kernels with weights for near-boundary points and interior points.
     *  Returns as array element [0] the kernel for the first data point, where no
     *  earlier points are present, as [1] the kernel where one earlier data point is present,
     *  and the last array element [m] is the kernel to apply in the interior.
     *  For the final points of the data series, the near-edge kernels[0, ... m-1] must be reversed.
     *  For the near-edge kernels, the first array element is the kernel element
     *  that should be applied to the edge point. */
    static double[][] makeKernels(int weightType, int degree, int m) {
        if (degree > 2*m)
            throw new IllegalArgumentException("Kernel half-width m too low for degree, min m="+(degree+1)/2);
        double[][] kernels = new double[m+1][];
        for (int pLeft=0; pLeft<=m; pLeft++)               //number of points left of the current point
            kernels[pLeft] = makeLeftKernel(weightType, degree, m, pLeft);
        return kernels;
    }

    /** Creates one Savitzky-Golay kernel with weights, for a given point ner the left boundary,
     *  where pLeft is the number of data points to the left, or the kernel for interior points
     *  if pLeft = m. */
    static double[] makeLeftKernel(int weightType, int degree, int m, int pLeft) {
        double scale = weightFunctionScale((double)(m-pLeft)/m, weightType);
        int pRight = (int)Math.floor((m+1)/scale);     //number of points right of the current point
        if (pRight+pLeft > 2*m) pRight = 2*m - pLeft;
        double[] weights = new double[pLeft+pRight+1];      //the weight function
        for (int i=0; i<=pRight; i++) {                     //we have more points at the right side
            double weight = weightFunction(weightType, i*scale/(m+1));
            weights[pLeft+i] = weight;
            if (i != 0 && i<=pLeft)
                weights[pLeft-i] = weight;
        }
        double[][] polynomials= new double[degree+1][pLeft+pRight+1]; //polynomials of order 0 to 'degree'
        Arrays.fill(polynomials[0], 1.);                    //0th degree, constant
        normalize(polynomials[0], weights);
        for (int o=1; o<=degree; o++) {
            for (int i=0; i<pLeft+pRight+1; i++)            //higher powers of x
                polynomials[o][i] = polynomials[o-1][i]*(i-pLeft);
        }
        //Modified Gram-Schmidt Orthonormalization
        for (int o=1; o<=degree; o++) {
            for (int u=0; u<o; u++) {
                double dotProd = dotProduct(polynomials[u], polynomials[o], weights);
                for (int i=0; i<pLeft+pRight+1; i++)
                    polynomials[o][i] -= polynomials[u][i]*dotProd;  //subtract projection on u
            }
            normalize(polynomials[o], weights);
        }
        //Finally the kernel: sum up contributions from each basis polynomial
        double[] kernel = new double[pLeft+pRight+1];
        for (int o=0; o<=degree; o++) {
            for (int i=0; i<pLeft+pRight+1; i++)
                kernel[i] += polynomials[o][i]*polynomials[o][pLeft]*weights[i];
        }
        return kernel;
   }

    /** The weight function of the SGW, where x=0 is the center, and the weight function becomes zero at x=1 */
    static double weightFunction(int weightType, double x) {
        final double decay=2; //for GAUSS only
        if (x <= -0.999999999999 || x >= 0.999999999999) return 0;
        if (weightType==NONE)
            return 1.;
        else if (weightType==GAUSS2)
            return Math.exp(-sqr(x)*decay) + Math.exp(-sqr(x-2)*decay) + Math.exp(-sqr(x+2)*decay) -
                    2*Math.exp(-decay) - Math.exp(-9*decay); //Gaussian-like alpha=2
        else if (weightType==HANN)
            return sqr(Math.cos(0.5*Math.PI*x)); //Hann
        else if (weightType==HANNSQR)
            return sqr(sqr(Math.cos(0.5*Math.PI*x))); //Hann-squared
        else if (weightType==HANNCUBE)
            return sqr(sqr(Math.cos(0.5*Math.PI*x)))*sqr(Math.cos(0.5*Math.PI*x)); //Hann-cube
        else throw new IllegalArgumentException("Undefined weight function: "+weightType);
    }

    /** Returns the scale factor for x for the weight function at near-edge points.
     *  @param missingFrac is the fraction of points that are outside the data range over
     *  the half-width m of the 'normal' kernel */
    static double weightFunctionScale(double missingFrac, int weightType) {
        double[] coeffs = weightScaleCoeffs[weightType];
        if (missingFrac<=0)
            return 1;
        else
            return 1-coeffs[0]/(1+coeffs[1]*Math.pow(missingFrac,coeffs[2]));
    }

    /** Dot product of two vectors with weights */
    static double dotProduct(double[] vector1, double[] vector2, double[] weights) {
        double sum=0;
        for (int i=0; i<vector1.length; i++)
            sum += vector1[i]*vector2[i]*weights[i];
        return sum;
    }

    /** Normalizes a vector to length=1 (with the given weights) */
    static void normalize(double[] vector, double[] weights) {
        double dotProd = dotProduct(vector, vector, weights);
        for (int i=0; i<vector.length; i++)
            vector[i] *= 1./Math.sqrt(dotProd);
    }

    static double sqr(double x) { return x*x; }
}
