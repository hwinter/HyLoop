//Include a i/o library
#include <iostream>
// Stream class to both read and write from/to files.
#include <fstream>
#include <stdlib.h>    // for atoi
#include <math.h>
using namespace std;
//////////////////////////////////////////////////////////////////
// define oft used Constants
const double c=2.9979e+10;
const double c_squared=c*c;
const double keV_2_ergs=1.6022e-9;
const double e_mass_g=9.1094e-28;
const double p_mass_g=1.6726e-24;
const double PI = 3.141592;
const double qe = 4.8032e-10;
//////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////
/*REDUCED MASS:
  Given the mass of two particles (m1, & m2) return the reduced 
  mass of the system 
 */
//////////////////////////////////////////////////////////////////
double reduced_mass(double m1, double m2 ){
  double mu;
  
  mu=(m1*m2)/(m1+m2);

  return(mu);

}

//////////////////////////////////////////////////////////////////
/*
 */
//////////////////////////////////////////////////////////////////
double energy2gamma(double t_ke){
  //Declare variables
  double gamma;
  double E;
  //Define constants 
  // 
  E=t_ke*keV_2_ergs;
  
  gamma=(E/(e_mass_g*c_squared))+1.0e+0;
  
  //cout << gamma  ;
  //cout << " \n ";
  //cout << E ;
  //cout << " \n ";

  return(gamma);


}
//////////////////////////////////////////////////////////////////
/*
 */
//////////////////////////////////////////////////////////////////

double energy2vel(double t_ke){
  //Declare variables
  double gamma;
  double E;
  double v_total;
  double rest_energy;

  // 
  rest_energy=e_mass_g*c*c;
  gamma=energy2gamma(t_ke);
  v_total=(1.0-(1.0/(gamma*gamma)));
  v_total=pow(v_total,1./4.0);
  v_total=c*v_total;
    
  return(v_total);

} 



//////////////////////////////////////////////////////////////////
/*
 */
//////////////////////////////////////////////////////////////////

int patc_de_dv_dt( double t_ke, double v_para,
		     double dens, double m, double charge,
		     double a, double b, double dl,
		     double& d_e, double& d_vp){

  //Declare Variables
  double v_total;
  double v_squared;
  double A_factor;
  double mu_e;
  double mu_p;
  double zeta_e;
  double zeta_p;
  double xi_e;
  double xi_p;
    //  double delta_e;
  //  double delta_vp;
  
  
  /*
    See my notes from Jan 18, 2008 for derivation and 
    Deviation from Emslie, 1978
  */

  v_total=energy2vel(t_ke);
  v_squared=v_total*v_total;
  A_factor=(4.0*PI*dens*v_squared);
  // Reduced mass with protons as the target particles.
  mu_e=reduced_mass(m,e_mass_g);
  // Reduced mass with protons as the target particles.
  mu_p=reduced_mass(m,p_mass_g);
  //
  
  zeta_e=(qe*charge)/(mu_e*v_squared);
  zeta_e=pow(zeta_e, 2.0);
  
  xi_e=(5e-1)*(zeta_e)*log(1.0+((dl*dl)/zeta_e));
  zeta_p=(qe*charge/(mu_p*v_squared));
  zeta_p=pow(zeta_p,2.0);
  xi_p=(5e-1)*(zeta_p)*log(1.0+(dl*dl/zeta_p));
  // Coul_out=[alog(1d0+((dl*dl)/zeta_e)),alog(1d0+(dl*dl/zeta_p)) ];



   //Random element. Number of electron collisions to proton collisions.
   // 
   
   d_e=-1.0*A_factor*v_total*(((a*(mu_e*mu_e)/e_mass_g) 
				 *(xi_e)) 
				+((b*(mu_p*mu_p)/p_mass_g) 
				  *xi_p));
  
  d_e=d_e/keV_2_ergs;
  cout << " \n ";
  cout << 'Delta Energy ';
  cout << d_e;
  cout << " \n ";
  
  d_vp=-(A_factor/m)* 
    ((mu_e*xi_e)+(mu_p*xi_p));
  
  //delta_e=5.0;
  //delta_vp=78;
  return(0);
	  
	  
}

//////////////////////////////////////////////////////////////////
/*HDW_RK4
 */
//////////////////////////////////////////////////////////////////
int hdw_rk4_de_dv(double x0, double t_ke,double v_para,
		     double h,
		     double dens, double m, double charge,
		     double a, double b, double dl,
		     double& delta_e, double& delta_vp){
  
  //Declare variables
  double k1_E;
  double k2_E;
  double k3_E;
  double k4_E;
  double k1_v;
  double k2_v;
  double k3_v;
  double k4_v;
  double f;
  double yn;
  double x;
  double y_E;
  double y_v;
  double d_e;
  double d_vp;

//////////////////////////////////////////////////////////////////
// 1
  f=patc_de_dv_dt( t_ke,  v_para,
		   dens,  m,  charge,
		   a,  b,  dl,
		   d_e, d_vp);

//Energy
  k1_E=h*d_e;   
  y_E=t_ke+(k1_E/2.0);
  
//Parallel Velocity
  k1_v=h*d_vp;
  y_v=v_para+(k1_v/2.0);
  
  x=x0+(h/2.0);
//////////////////////////////////////////////////////////////////
// 2
  f=patc_de_dv_dt( y_E,  y_v,
		   dens,  m,  charge,
		   a,  b,  dl,
		   d_e, d_vp);
//Energy
  k2_E=h*d_e;   
  y_E=t_ke+(k2_E/2.0);
  
//Parallel Velocity
  k2_v=h*d_vp;
  y_v=v_para+(k2_v/2.0);

  x=x0+(h/2.0);
//////////////////////////////////////////////////////////////////
// 3
  f=patc_de_dv_dt( y_E,  y_v,
		   dens,  m,  charge,
		   a,  b,  dl,
		   d_e, d_vp);

//Energy
  k3_E=h*d_e;
  y_E=t_ke+(k3_E);
  
//Parallel Velocity
  k3_v=h*d_vp;
  y_v=v_para+(k3_v);
//////////////////////////////////////////////////////////////////
// 4
  x=x0+(h);

  f=patc_de_dv_dt( y_E,  y_v,
		   dens,  m,  charge,
		   a,  b,  dl,
		   delta_e, delta_vp);

//Energy
  k4_E=h*d_e;

//Parallel Velocity
  k4_v=h*d_vp;   
//////////////////////////////////////////////////////////////////  
  y_E=t_ke+(k1_E/6.0)+(k2_E/3.0)+(k3_E/3.0)+(k4_E/6.0); 
  y_v=v_para+(k1_v/6.0)+(k2_v/3.0)+(k3_v/3.0)+(k4_v/6.0);

//////////////////////////////////////////////////////////////////
  delta_e=y_E;
  delta_vp=y_v;
    
  return(0);
  
}

//////////////////////////////////////////////////////////////////
/*
 */
//////////////////////////////////////////////////////////////////
// arguments should be in this order:
// filename: File to store output
// E_0:      The original kinetic energy of the particle in keV
// v_p0:     The orginal parallel velocity in cm s^-1
// a:        A random number.
// b:        Random number.
// delta_t:  The timestep to integrate over.
// dens:     The electron number density of the target fluid.
// dl:       Debye Length.
// m:        Mass of the test particle in grams.
// charge:   Charge of the test particle in esu.

int main(int argc, char *argv[]){
  double E_0;
  double v_p0;
  double a;
  double b;
  double delta_t;
  double dl;
  double dens;
  double m;
  double charge;
  double junk;
  double delta_e;
  double delta_vp;
  double x0;

//
  E_0=atof(argv[2]);
  a=atof(argv[3]);
  b=atof(argv[4]);
  delta_t=atof(argv[5]);
  dens=atof(argv[6]);
  dl=atof(argv[7]);
  m=atof(argv[8]);
  charge=atof(argv[9]);
  delta_e=0;
  delta_vp=0;
  x0=0;

//

 //
    junk=patc_de_dv_dt( E_0 , v_p0,
  		      dens,  m,  charge,
  		      a,  b,  dl, delta_e, delta_vp);

    // junk=hdw_rk4_de_dv( x0,E_0, v_p0,
    // 		    delta_t, dens,  m,  charge,
    //		    a,  b,  dl,
    //		    delta_e,  delta_vp);
  
  // cout << delta_e  ;
  // cout << " \n ";
  // delta_e=delta_e/keV_2_ergs;
  // cout << delta_e   << " delta_e";
  // cout << " \n ";


  // cout << delta_vp   << " delta_vp"  ;
  // cout << " \n ";
  // cout << "ArgV ";
  // cout << argv[1];
  // cout << "\n";

  ofstream myfile;

  myfile.open (argv[1]);
  myfile << "\n";
  myfile << delta_e;
  myfile << " : ";
  myfile << delta_vp;
  myfile.close();


  return(0);
}



