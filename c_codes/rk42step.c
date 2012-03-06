/****************************************************************/
/* Module : RK4.c 						*/
/* Section: 10.2						*/
/* Cheney-Kincaid, Numerical Mathematics and Computing, 5th ed, */
/* Brooks/Cole Publ. Co.                                        */
/* Copyright (c) 2003.  All rights reserved.                    */
/* For educational use with the Cheney-Kincaid textbook.        */
/* Absolutely no warranty implied or expressed.                 */   
/* 								*/
/* Description: Runge-Kutta 4th Order				*/
/*								*/
/****************************************************************/

#include <stdio.h>
#include <stdlib.h>
#include <math.h>



#include <stdio.h>
#include <stdlib.h>

float f(float t, float x); /* define prototype */


float f(float t, float x)
{
  return (2 + (x - t - 1) * (x - t - 1));
}


void rk4(float f(float, float), float t, float x, float h, int n)
{
  int k;
  float F1, F2, F3, F4, ta;

  ta = t;

  for (k = 1; k <= n; k++)
  {
    F1 = h * f(t,x);
    F2 = h * f(t + 0.5 * h, x + F1 * 0.5);
    F3 = h * f(t + 0.5 * h, x + F2 * 0.5);
    F4 = h * f(t + h, x + F3);
    x += (F1 + 2 * (F2 + F3) + F4) / 6;

    t = ta + k * h;

    printf("k = %d t = %f x = %f\n", k, t, x);
  }

}
