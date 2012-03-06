
//Include a i/o library
#include <iostream>
#include <math.h>
using namespace std;


//////////////////////////////////////////////////////////////////
/*

 */
//////////////////////////////////////////////////////////////////
double derivs(double x0, double y0){

  double y;

  y=2.0*x0;

  return(y);
}
//////////////////////////////////////////////////////////////////
/*HDW_RK4
 */
//////////////////////////////////////////////////////////////////
double hdw_rk4(double x0, double y0, double h){
  
  //Declare variables
  double k1;
  double k2;
  double k3;
  double k4;
  double f;
  double yn;
  double x;
  double y;

  f=derivs(x0, y0);
  k1=h*f;
  
  x=x0+(h/2.0);
  y=y0+(k1/2.0);
  f=derivs(x, y);
  k2=h*f;
  
  x=x0+(h/2.0);
  y=y0+(k2/2.0);
  f=derivs(x, y);
  k3=h*f;
  
  x=x0+h;
  y=y0+(k3);
  f=derivs(x, y);
  k4=h*f; 
  
  yn=y0+(k1/6.0)+(k2/3.0)+(k3/3.0)+(k4/6.0);

  return(yn);
  
}
//////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////
int main(){
  
  //Declare variables
  double x0;
  double y0;
  double h;
  double yn;
  double ans;

  x0=1.0;
  y0=0.0;
  h=1.0;

  yn=hdw_rk4(x0, y0, h);

  cout << yn;
  cout << " \n ";
  
  ans=(4.0-1.0);

    
  cout << (yn-ans)/ans;
  cout << " \n ";
  
}
//////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////





