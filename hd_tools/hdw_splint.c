/* $Id:$ */
/* IDL CALL_EXTERNAL routine adopted from CK_SPLINT.C, 
 * from C. C. Kankelborg's thesis.  Do a linear
 * interpolation in an array.
 * 
 * History:
 *     (Written by B. Handy, sometime 1999)
 *     08-Sep-1999 (BNH) - If NaN is passed in, die gracefully.
 */

#include <stdio.h>
/* Include this to get the IEEE finite(3) function. */
#include <math.h>
/* #include <stdlib.h> */
/* #include <fp.h> */

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

double hdw_splint(argc, argv)
int argc;
void *argv[];
{
   extern int which_index();

   double h;
   int j, klo, khi;
   int n = *(int *)argv[0];     /* The length of x, f(x)         */
   int n_x1 = *(int *)argv[3];  /* Number of interpolated points */

   double *x1;                  /* Interpolated points */
   double *xp;                  /* The x-coordinate    */
   double *fp;                  /* The function f(x)   */
   double *rp;                  /* The returned interpolated values */
   xp = (double *)argv[1];
   fp = (double *)argv[2];
   x1 = (double *)argv[4];
   rp = (double *)argv[5];

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
       
           if (h == 0.0)      /* step values of 0 don't interpolate well */
	       *(rp+j) = 0.0;
   
           *(rp+j) = ((*(fp+khi) - *(fp+klo)) / (*(xp+khi) - *(xp+klo))) * 
	       (*(x1+j) - *(xp+klo)) + *(fp+klo);
       }
   }
   return(0);
}
