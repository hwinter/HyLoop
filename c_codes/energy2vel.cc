//Include a i/o library
#include <iostream>
//Include the math library
#include <math.h>
using namespace std;

double energy2gamma(double t_ke){
  //Declare variables
  double keV_2_ergs;
  double e_mass_g;
  double c_squared;
  double gamma;
  double E;
  //Define constants 
  keV_2_ergs=1.6022e-9;
  e_mass_g= 9.1094e-28;
  c_squared=(2.9979e+10)*(2.9979e+10);
  // 
  E=t_ke*keV_2_ergs;
  
  gamma=(E/(e_mass_g*c_squared))+1.0e+0;
  // 
  cout << gamma  ;
  cout << " \n ";
  cout << E ;
  cout << " \n ";

  return(gamma);


}


double energy2vel(double t_ke){
  //Declare variables
  double keV_2_ergs;
  double e_mass_g;
  double c;
  double c_squared;
  double gamma;
  double E;
  double v_total;
  //Define constants 
  keV_2_ergs=1.6022e-9;
  e_mass_g= 9.1094e-28;
  c=2.9979e+10;
  c_squared=(2.9979e+10)*(2.9979e+10);
  // 
  gamma=energy2gamma(t_ke);
  v_total=pow((1.0/gamma),2.0);
  v_total=c*(sqrt(1.0-v_total));
  cout << v_total;
  return(1);
} 

int main(){
  double gamma;
  double t_ke;
  gamma=energy2gamma(40);
  
  cout << gamma  ;
  cout << " \n ";
  
 
}



