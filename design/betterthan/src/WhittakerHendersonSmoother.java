/* 
 * WhittakerHendersonSmoother
 */

import java.util.Arrays;

/**
 *  A simple Java implementation of Whittaker-Henderson smoothing for
 *  data at equally spaced points, popularized by P.H.C. Eilers in
 *  "A Perfect Smoother", Anal. Chem. 75, 3631 (2003).
 *  <p>
 *  It minimizes
 *  <p>
 *     sum(f - y)^2 + sum(lambda * f'(p))
 *  </p>
 *  where y are the data, f are the smoothed data, and f'(p) is the p-th
 *  derivative of the smoothed function evaluated numerically. In other
 *  words, the filter imposes a penalty on the p-th derivative of the
 *  data, which is taken as a measure of non-smoothness.
 *  Smoothing increases with increasing value of lambda.
 *  <p>
 *  The current implementation works up to p = 5; usually one should use
 *  p = 2 or 3.
 *  <p>
 *  For points far from the boundaries of the data series, the frequency
 *  response of the smoother is given by
 *  <p>
 *    1/(1+lambda*(2-2*cos(omega))^2p);
 *  </p>
 *  where n is the order of the penalized derivative and
 *  omega = 2*pi*f/fs, with fs being the sampling frequency
 *  (reciprocal of the distance between the data points).
 *  <p>
 *  Note that strong smoothing leads to numerical noise (which is smoothed
 *  similar to the input data, thus not obvious in the output).
 *  For lambda = 1e9, the noise is about 1e-6 times the magnitude of the
 *  data. Since higher p values require a higher value of lambda for
 *  the same extent of smoothing (the same band width), numerical noise
 *  is increasingly bothersome for large p, not for p <= 2.
 *
 *  <h3>
 *  Implementation notes:
 *  </h3>
 *  Storage of symmetric or triangular band-diagonal matrices:
 *  For a symmetric band-diagonal matrix with band width 2 m - 1
 *  we store only the lower right side in b:
 *  <pre>
 *     b(0, i)   are diagonal elements a(i,i)
 *     b(1, i)   are elements a(i+1, i)
 *     ...
 *     b(m-1, i) are bottommost (leftmost) elements a(i+m-1, i)
 *  </pre>
 *  where i runs from 0 to n-1 for b(0, i) and 0 to n - m for the
 *  further elements at a distance of m from the diagonal.
 * 
 *  A lower triangular band matrix is stored exactly the same way.
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
 *  Author: Michael Schmid, IAP/TU Wien, 2021.
 *          https://www.iap.tuwien.ac.at/www/surface/group/schmid
 */

public class WhittakerHendersonSmoother {
    /** This implementation is for a penalty derivative order p up to 5 */
    public final static int MAX_ORDER = 5;
    /** Coefficients for numerical differentiation for p = 1
     *  to <code>MAX_ORDER</code> */
    private final static double[][] DIFF_COEFF = new double[][] {
                {-1,  1},               //penalty on 1st derivative
                { 1, -2,  1},
                {-1,  3, -3, 1},
                { 1, -4,  6, -4,  1},
                {-1,  5,-10, 10, -5,  1} //5th derivative. 5 = MAX_ORDER
            };
    /** Coefficients for converting noise gain to lambda */
    private final static double[] LAMBDA_FOR_NOISE_GAIN = new double[]
            {0.06284, 0.005010, 0.0004660, 4.520e-05, 4.467e-06};
    /** The Cholesky-decomposed triangular matrix in the form explained above */
    private double[][] matrix;

    /**
     * Creates a WhittakerHendersonSmoother for data of a given length and with a
     * given penalty order and smoothing parameter lambda. This
     * constructor is useful for repeated smoothing operations with
     * the same parameters and data sets of the same length.
     * Otherwise the static <code>smooth(double[], int, double)</code>
     * method is more convenient.
     * @param length Number of data points of the data that will be smoothed
     * @param order  Order of the derivative that will be penalized;
     *        typically 2 or 3.
     * @param lambda Smoothing parameter, @see bandwidthToLambda.
     */
    public WhittakerHendersonSmoother(int length, int order, double lambda) {
        matrix = makeDprimeD(order, length);
        timesLambdaPlusIdent(matrix, lambda);
        choleskyL(matrix);
    }

    /**
     * Smooths the data with the parameters passed with the constructor.
     * @param data The input data.
     * @param out  The output array; may be null. If <code>out</code> is supplied
     *          and has the correct size, it is used for the output. <code>out</code>
     *          may be null or the input array <code>data</code>; in the latter case
     *          the input is overwritten.
     * @return  The smoothed data. If <code>out</code> is non-null and has the correct
     *          size, this is the <code>out</code> array.
     */
    public double[] smooth(double[] data, double[] out) {
        if (data.length != matrix[0].length)
            throw new IllegalArgumentException("Data length mismatch, "
                    +data.length+" vs. "+matrix[0].length);
        out = solve(matrix, data, out);
        return out;
    }

    /**
     * Smooths the data and with the given penalty order and smoothing
     * parameter lambda. When smoothing multiple data sets with the same
     * length, using the constructor and then smooth(double[], double[])
     * will be more efficient.
     * @param data   The input data.
     * @param order  Order of the derivative that will be penalized;
     *          typically 2 or 3.
     * @param lambda Smoothing parameter; should not be excessively high.
     *          See <code>bandwidthToLambda</code>.
     * @return  The smoothed data.
     */
    public static double[] smooth(double[] data, int order, double lambda) {
        WhittakerHendersonSmoother smoother = new WhittakerHendersonSmoother(data.length, order, lambda);
        return smoother.smooth(data, null);
    }

    /**
     * Smooths the data in a way comparable to a traditional Savitzky-Golay
     * filter with the given parameters <code>degree</code> and <code>m</code>.
     * @param data The input data.
     * @param degree The degree of the polynomial fit used in the SG filter.
     * @param m The half-width of the SG kernel. The kernel size of the SG
     *          filter, i.e. the number of points for fitting the polynomial
     *          is <code>2*m + 1</code>.
     *          Note that very strong smoothing will lead to numerical noise;
     *          recommended limits for m are 700, 190, 100, and 75 for
     *          Savitzky-Golay degrees 2, 4, 6, and 8, respectively.
     * @return  The smoothed data.
     */
    public static double[] smoothLikeSavitzkyGolay(double[] data, int degree, int m) {
        int order = degree/2 + 1;
        double bandwidth = savitzkyGolayBandwidth(degree, m);
        double lambda = bandwidthToLambda(order, bandwidth);
        return smooth(data, order, lambda);
    }

    /**
     * Calculates the lambda smoothing parameter for a given penalty derivative
     * order, given the desired band width, i.e., the frequency where the response
     * decreases to -3 dB, i.e., 1/sqrt(2).
     * This band width is valid for points far from the boundaries of the data.
     * @param order     The order p of the penalty derivative, 1 to 5 (typically 2 or 3)
     * @param bandwidth The desired band width, with respect to the sampling frequency.
     *          The value of <code>bandwidth</code> must be less than 0.5
     *          (the Nyquist frequency).
     * @return  The lambda parameter for this band width. Note that very high
     *          lambda parameters lead to high numerical noise in smoothing.
     *          It is recommended to use only lambda values below 1e9, which lead to
     *          relative numerical noise below 1e-6. For a given bandwidth, the
     *          lambda value can be reduced by chosing a lower order p.
     */
    public static double bandwidthToLambda(int order, double bandwidth) {
        if (bandwidth <= 0 || bandwidth >= 0.5)
            throw new IllegalArgumentException("Invalid bandwidth value: "+bandwidth);
        double omega = 2*Math.PI*bandwidth;
        double cosTerm = 2*(1 - Math.cos(omega));
        double cosPower = cosTerm;
        for (int i=1; i<order; i++)
            cosPower *=cosTerm;     //finally results in (2-2*cos(omega))^order
        double lambda = (Math.sqrt(2) - 1)/cosPower;
        return lambda;
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
     * Calculates an approximation of the lambda smoothing parameter for a
     * given white noise gain. This is for points far from the boundaries of the data;
     * the noise gain is much higher near the boundaries.
     * The result has good accuracy for noise gains below 0.1. For a noise gain
     * of 0.4, the actual noise gains are about 10% higher. For weaker smoothing
     * than this, it is advisable to use a penalty order of 2 and/or use other methods.
     * @param order     The order p of the penalty derivative, 1 to 5 (typically 2 or 3)
     * @param noiseGain The factor by which white noise should be suppressed.
     * @return The lambda parameter for this noise gain.
     */
    public static double noiseGainToLambda(int order, double noiseGain) {
        double gPower = noiseGain;
        for (int i=1; i<order; i++)
            gPower *=noiseGain;     //finally results in noiseGain^order
        double lambda = LAMBDA_FOR_NOISE_GAIN[order]/(gPower+gPower);
        return lambda;
    }

    /**
     * Creates a symmetric band-diagonal matrix D'*D where D is the n-th
     * derivative matrix and D' its transpose.
     * @param order The order of the derivative
     * @param size The size of the matrix created
     * @return The D'*D matrix, with b[0] holding the diagonal elements and
     *         b[1] the elements below the diagonal, etc.
     *         Note that the sub-arrays of <code>b</code> do nothave equal length:
     *         <code>b[n].length</code> equals <code>size - n</code>.
     */
    static double[][] makeDprimeD(int order, int size) {
        if (order < 1 || order > MAX_ORDER)
            throw new IllegalArgumentException("Invalid order "+order);
        if (size < order)
            throw new IllegalArgumentException("Order ("+order+
                    ") must be less than number of points ("+size+")");
        
        double[] coeffs = DIFF_COEFF[order - 1];
        double[][] out = new double[order+1][];
        for (int d=0; d<order+1; d++)       //'d' is distance from diagonal
            out[d] = new double[size-d];
        for (int d=0; d<order+1; d++) {
            int len = out[d].length;
            for (int i=0; i<(len+1)/2; i++) {
                double sum = 0.;
                for (int j=Math.max(0, i-len+coeffs.length-d);
                        j<i+1 && j<coeffs.length-d; j++)
                    sum += coeffs[j] * coeffs[j+d];
                out[d][i] = sum;
                out[d][len-1-i] = sum;
            }
        }
        return out;
    }

    /** 
     *  Modifies a symmetric band-diagonal matrix b so that the output is
     *  1 + lambda*b where 1 is the identity matrix
     * @param b The matrix, with b[0] holding the diagonal elements and
     *         b[1] the elements below the diagonal, etc.
     *         <code>b</code> is replaced by the output (overwritten).
     * @param lambda The factor applied to the matrix before adding the
     *         identity matrix.
     *  */
    static void timesLambdaPlusIdent(double[][] b, double lambda) {
        for (int i=0; i<b[0].length; i++)
            b[0][i] = 1.0 + b[0][i]*lambda;  //diagonal elements with identity added
        for (int d=1; d<b.length; d++)
            for (int i=0; i<b[d].length; i++)
                b[d][i] = b[d][i]*lambda;    //off-diagonal elements
    }

    /**
     *  Cholesky decomposition of a symmetric band-diagonal matrix b.
     *  The input is replaced by the lower left trianglar matrix.
     * @param b The matrix, with b[0] holding the diagonal elements and
     *          b[1] the elements below the diagonal, etc.
     *          <code>b</code> is replaced by the output (overwritten).
     * */
    static void choleskyL(double[][] b) {
        int n = b[0].length;
        int dmax = b.length - 1;
        for (int i=0; i<n; i++) {                           //for i=0 to n-1
            for (int j=Math.max(0, i-dmax); j<=i; j++) {    //for j=0 to i
                double sum = 0.;
                for (int k=Math.max(0, i-dmax); k<j; k++) { //for k=0 to j-1
                    int dAik = i-k;  //first index in b for accessing a[i,k]
                    int dAjk = j-k;
                    sum += b[dAik][k] * b[dAjk][k];         //sum += a[i,k]*a[j,k]
                }
                if (i == j) {
                    double sqrtArg = b[0][i] - sum;
                    if (sqrtArg <= 0)
                        throw new RuntimeException(
                                "Cholesky decomposition: Matrix is not positive definite");
                    b[0][i] = Math.sqrt(sqrtArg);           //a[i,i] = sqrt(a[i,i] - sum)
                } else {
                    int dAij = i-j;  //first index in b for accessing a[i,j]
                    b[dAij][j] = 1./b[0][j] * (b[dAij][j] - sum);   //a[i,j] = 1/(a[j,j] * (a[i,j] - sum))
                }
            }
        }
    }

    /** 
     *  Solves the equation b*y = vec for y (forward substitution)
     *  and thereafter b'*x = y, where b' is the transposed (back substitution)
     * @param b The matrix, with b[0] holding the diagonal elements and
     *          b[1] the elements below the diagonal, etc.
     * @param vec The vector at the right-hand side. For data smoothing, this
     *          is the data
     * @param out The output array; may be null. If <code>out</code> is supplied
     *          and has the correct size, it is used for the output. <code>out</code>
     *          may be null or the input array <code>vec</code>; in the latter case
     *          the input is overwritten.
     * @return  The vector x resulting from forward and back subsitution. If <code>b</code>
     *          is the result of Cholesky decomposition, this is the solution for
     *          A*x = vec. For data smoothing, <code>x</code> holds the smoothed data.
     */
    static double[] solve(double[][] b, double[] vec, double[] out) {
        if (out == null || out.length != vec.length)
            out = new double[vec.length];
        int n = b[0].length;
        int dmax = b.length - 1;
        for (int i=0; i<n; i++) {
            double sum = 0;
            for (int j=Math.max(0, i-dmax); j<i; j++) {
                int dAij = i-j;  //first index in b for accessing a[i,j]
                sum += b[dAij][j]*out[j];
            }
            out[i] = (vec[i] - sum)/b[0][i]; //denominator is diagonal element a[i,i]
        }
        for (int i=n-1; i>=0; i--) {
            double sum = 0;
            for (int j=i+1; j<Math.min(i+dmax+1, n); j++) {
                int dAji = j-i;
                sum += b[dAji][i]*out[j];
            }
            out[i] = (out[i] - sum)/b[0][i];
        }
        return out;
    }
}
