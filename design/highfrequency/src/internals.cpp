#include <RcppArmadillo.h>
using namespace arma;
using namespace Rcpp;



//' @keywords internal
// [[Rcpp::export]]
arma::mat colCumsum(const arma::mat& x) {
  arma::mat y = x;
  // We loop through the columns of x and apply cumsum
  for(uword col = 0; col < x.n_cols; col++){
    y.col(col) = cumsum(x.col(col));
  }
  
  return(y);
  
}


//' @keywords internal
// [[Rcpp::export]]
Rcpp::List refreshTimeMatching(const arma::mat& x, arma::vec& idx) {
  
  const uword N = x.n_rows;
  const uword D = x.n_cols;
  
  // Create N by D matrix filled with NA's
  arma::mat tmp(N, D);
  tmp.fill(NA_REAL);
  
  arma::rowvec lastValues = x.row(0);

  // Here, lastValues has no nans and we can put all the observations into the tmp matrix.
  // This a special case for the beginning of the algorithm.
  if(!lastValues.has_nan()){
    tmp.row(0) = lastValues;
    lastValues.fill(NA_REAL);
  }
  
  
  
  for(uword n = 1; n < N; n++){
    
    
    for(uword d = 0; d < D; d++){
    
      if(!std::isnan(x(n,d))){
        lastValues(d) = x(n,d);
      }
      
    }
    
    
    // Check if we have filled the last value vector with values.
    if(lastValues.is_finite()){
      tmp.row(n) = lastValues;
      lastValues.fill(NA_REAL);
    }
    
  }
  
  arma::uvec keep = arma::find_finite(tmp.col(0));
  
  //tmp.rows(keep), 
  tmp = tmp.rows(keep);
  idx = idx.elem(keep);
  
  return Rcpp::List::create(Rcpp::Named("data") = tmp,
                            Rcpp::Named("indices") = idx);
  
}


//' @keywords internal
inline double weightedSumPreAveragingInternal(const arma::vec& x, const arma::vec& series){
  
  return(arma::dot(x,series));
}

//' @keywords internal
// [[Rcpp::export]]
arma::mat preAveragingReturnsInternal(arma::mat& ret, const int kn){
  
  const int N = ret.n_rows + 1;
  const int D = ret.n_cols;
  arma::mat out(N-kn + 1, D);
  
  arma::vec weights = arma::linspace(1,kn-1, kn-1)/kn;
  arma::vec foo = 1-weights;
  
  weights(find(weights > (1-weights))) = foo(find(weights > (1-weights)));



  for(int i = 0; i < N - kn + 1; i++) {
    // Do column wise multiplication of our weights on the returns.
    out.row(i) = sum(ret(span(i,i+kn-2), span(0, D-1)).each_col() % weights , 0);

  }

  
  return(out);
  
  
}



// Armadillo version of bisect_left needed for the lead-lag estimation, didn't find a version in base R
// [[Rcpp::export]]
arma::uword findFirst(arma::vec& x , const int thresh){
  arma::uword i;
  for(i = 0; i < x.n_elem; i++){ 
    
    if(x[i] >= thresh){
      return i; 
    }
    
  }
  return i; 
}


// [[Rcpp::export]]
bool overlap(double min1, double max1, double min2, double max2){
  return (std::max(0.0, ((double) std::min(max1, max2) - (double) std::max(min1, min2))) > 0.0);
}


// [[Rcpp::export]]
arma::vec mSeq(arma::vec starts, arma::vec ends, double scaleFactor){ // multiple sequence with same step length but differing start and end (the differences between these are the same)
  
  arma::mat out = mat(floor((ends(0) - starts(0))/scaleFactor) + 1, starts.n_elem);

  for(arma::uword j = 0; j < out.n_cols; j++){
    out.col(j) = regspace(starts(j), scaleFactor, ends(j));
  }
  //arma::mat out = regspace<arma::mat>(starts, scaleFactor, ends);
  return vectorise(out);
  
}


// The following code is modified from the repository: https://github.com/coatless/r-to-armadillo which is a collection of R functions written in C++
//[[Rcpp::export]]
arma::vec cfilter(arma::vec x, arma::vec filter)
{
  
  int nx = x.n_elem;
  int nf = filter.n_elem;
  int nshift = nf/2;
  
  double z, tmp;
  
  
  arma::vec out = arma::zeros<arma::vec>(nx);
  
  for(int i = 0; i < nx; i++) {
    z = 0;
    if(i + nshift - (nf - 1) < 0 || i + nshift >= nx) {
      out(i) = NA_REAL;
      continue;
    }
    for(int j = std::max(0, nshift + i - nx); j < std::min(nf, i + nshift + 1) ; j++) {
      tmp = x(i + nshift - j);
      z += filter(j) * tmp;
    }
    out(i) = z;
  }
  
  return out;
}


//[[Rcpp::export]]
arma::vec mldivide(arma::mat A, arma::vec B){
  return(arma::solve(A,B));
}


//[[Rcpp::export]]
arma::mat rollApplyMinWrapper(const arma::mat& x){
  
  arma::mat out = arma::mat(x.n_rows - 1, x.n_cols); // One row less than the input as we take min of i and i-1
  const arma::uword N = x.n_cols;
  for(arma::uword i = 1; i < x.n_rows; i++){
    out.row(i-1) = min(x(span(i-1, i), span(0, N-1)), 0);
  }
  return(out);
}

//[[Rcpp::export]]
arma::mat rollApplyMedianWrapper(const arma::mat& x){
  
  arma::mat out = arma::mat(x.n_rows - 2, x.n_cols);
  const arma::uword N = x.n_cols;
  
  for(arma::uword i = 1; i < x.n_rows - 1; i++){
    out.row(i-1) = median(x(span(i - 1, i + 1), span(0, N - 1)), 0);
  }
  return(out);
  
}

//[[Rcpp::export]]
arma::mat rollApplyProdWrapper(const arma::mat& x, int m){
  m = m - 1;
  arma::mat out = arma::mat(x.n_rows - m, x.n_cols); 
  const arma::uword N = x.n_cols;
  for(arma::uword i = m; i < x.n_rows; i++){
    out.row(i-m) = prod(x(span(i-m, i), span(0, N-1)), 0);
  }
  return(out);
  
}




//[[Rcpp::export]]
arma::vec tickGrouping_RETURNS(const int end, const int size){
  arma::vec out = arma::zeros<vec>(end);
  int grp = 1;
  int cnt = 0;
  
  for (int i = size; i < end; i ++){
    out(i) = grp;
    cnt += 1;
    if(cnt == size){
      cnt = 0;
      grp += 1;
    }
  }
  return(out);
}
