/* This Stan demo of probalistic appraoch of PDE solution.
   It uses Walk-on-sphere method to calculate Laplace equ
   solution on a rectangle.
 */

/* run with */
/* .harmonic sample num_samples=1 algorithm=fixed_param data file=./harmonic.data.R */
functions {
  real[] rect_boundary_x() {
    real xb[2] = { 0.0, 1.0 };  /* rectangle boundary */
    return xb;
  }
  real[] rect_boundary_y() {
    real yb[2] = { 0.0, 1.0 };  /* rectangle boundary */
    return yb;
  }
  real bc(real x, real y) {
    real xb[2] = rect_boundary_x();
    real yb[2] = rect_boundary_y();
    real val;
    if (x == xb[1]) {           /* left boundary */
      val = 0.0;
    } else if ( x == xb[2]) {   /* right boundary */
      val = 0.0;
    } else if ( y == yb[1]) {   /* lower boundary */
      val = 0.0;
    } else if ( y == yb[2]) {   /* upper boundary */
      if (x <= 2.0/3.0)
        val = 75*x;
      else
        val = 150 * (1-x);
    }
    return val;
  }

  real rectangle_wos_rng(real x, real y, real tol) {
    real xb[2] = rect_boundary_x();
    real yb[2] = rect_boundary_y();
    real res[3] = {x, y, 0.0};
    real dist[4] = { xb[2] - res[1], res[1] - xb[1], yb[2] - res[2], res[2] - yb[1]};
    real r = min(dist);
    real val;
    while (r > tol) {
      real theta = uniform_rng(0, 2*pi());
      res[1] = res[1] + r * cos(theta);
      res[2] = res[2] + r * sin(theta);
      dist = { xb[2] - res[1], res[1] - xb[1], yb[2] - res[2], res[2] - yb[1]};      
      r = min(dist);      
      res[3] = r;
    }
    if (dist[1] < tol ) {       /* right boundary */
      res[1] = xb[2];
    } else if (dist[2] < tol ) { /* left boundary */ 
      res[1] = xb[1];
    } else if (dist[3] < tol ) { /* upper boundary */ 
      res[2] = yb[2];
    } else if (dist[4] < tol ) { /* lower boundary */
      res[2] = yb[1];
    }
    val = bc(res[1], res[2]);
    res[3] = val;
    return val;
  }
}

data{
  real tolerance;
  int m;
  int n;
  int N;
}

transformed data {
  vector[N] bcsample;
  real x;
  real y;
  real hm = 1.0/m;
  real hn = 1.0/n;
  real sol;
  for ( i in 1:m+1 ) {
    for ( j in 1:n+1 ) {
      x = (i-1)*hm;
      y = (j-1)*hn;
      for ( k in 1:N ) {
        bcsample[k] = rectangle_wos_rng(x, y, tolerance);        
      }
      sol = mean(bcsample);
    }
  }
}

