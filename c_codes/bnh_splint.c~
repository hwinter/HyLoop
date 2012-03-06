/* $Id:$ */
/* IDL CALL_EXTERNAL routine adopted from CK_SPLINT.C, 
 * from C. C. Kankelborg's thesis.  Do a linear
 * interpolation in an array.
 * 
 * History:
 *     (Written by B. Handy, sometime 1999)
 *     08-Sep-1999 (BNH) - If NaN is passed in, die gracefully.
 */

/* The first two includes are necessary for IDL call_external. */ 
#include <stdio.h>
#include "idl_export.h"
/* Include this to get the IEEE finite(3) function. */
#include <math.h>
/* #include <stdlib.h> */
/* #include <fp.h> */


int which_index(n, value, fp)
double *fp, value;
int n;
{
    static int i=0;
    int j;

    if (i == n) {
/*      fprintf(stderr, "DOH!  I == N, set i=0..\n"); */
        i = 0;
/*        sleep(15); */
    }

    do {
	if (*(fp+i+1) < value) i++;
	else if (*(fp+i) > value) i--;
	else return i;
    } while (i >= 0 && i < n);
    fprintf(stdout, "which_index():  value = %e out of range.\n", value);
    fprintf(stdout, "which_index():  n     = %d\n", n);
    fprintf(stdout, "which_index():  i     = %d\n", i);
    if (n <= 15) {
        for (j=0; j<n; j++) {
          fprintf(stdout, "which_index(): fp[%d] = %f\n", j, *(fp+j));
        }
    }
    return n;       /* Return n iff the argument is out of range. */
}

/* The values passed to this function:
 *     
 *     n    - how big the function is
 *     x    - known function points (n elements)
 *     f(x) - function at those points (n elements)
 *     n_x1 - How big is the interpolated array
 *     x1   - value we want to interpolate at (1 element)
 *     ans  - the returned answers
 *
 * --> So, we're going to return the linear interpolation of:
 *         y1 = f(x1), where x1 is an array of doubles
 */ 

double bnh_splint(int n, double *xp, double *fp, int n_x1, double *x1, double *rp)
//int argc;
//void *argv[];
{
   extern int which_index();

   double h;
   int j, klo, khi;
  // int n = *(int *)argv[0];     /* The length of x, f(x)         */
  // int n_x1 = *(int *)argv[3];  /* Number of interpolated points */

   //double *x1;                  /* Interpolated points */
   //double *xp;                  /* The x-coordinate    */
   //double *fp;                  /* The function f(x)   */
   //double *rp;                  /* The returned interpolated values */
   //xp = (double *)argv[1];
   //fp = (double *)argv[2];
   //x1 = (double *)argv[4];
   //rp = (double *)argv[5];

   /* Check that input lambda values are finite.  (WRONG)
   if (!finite(x1)) {
       *(rp) = *(x1);
       return(1);
   }

   * End of bogus finite check */

   for (j=0; j<n_x1; j++) {
       if (!finite(*(x1+j))) {
           *(rp+j) = *(x1+j);
       } else {
           klo = which_index(n, *(x1+j), xp);

           khi = klo + 1;
       
           if (h == 0.0)      // step values of 0 don't interpolate well
	       *(rp+j) = 0.0;
   
           *(rp+j) = ((*(fp+khi) - *(fp+klo)) / (*(xp+khi) - *(xp+klo))) * 
	       (*(x1+j) - *(xp+klo)) + *(fp+klo);
       }
   }
   return(0);
}
