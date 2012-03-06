







/** Function for generating random numbers in a specified pattern
 *The goal of this program in particular is to generate x anf y coordinates 
 *in a power law distribution
 */

#include<stdio.h>
#include<time.h>
#include<stdlib.h>
#include<gsl/gsl_randist.h>
#include<gsl/gsl_rng.h>
#include<math.h>
#include<gsl/gsl_odeiv.h>
#include<gsl/gsl_matrix.h>
#include<string.h>

/*********************************************
 **  Define all of the initial Conditions   **
 **                                         **
 *********************************************/

#define total_time 100.0
#define e 1.602176//*pow(10.,-19.)
#define m_e 9.10938188//*pow(10.,-31.)
#define init_v 1.0
#define box_width 20.
#define box_height 20.
#define B_X 0
#define B_Y 0
#define B_Z 0.5
#define h .01 //RK time-step
size_t dimensions=6;
const double sigma=(M_PI/4);
unsigned long int total_coordinates;
unsigned long int total_total;
/* Set a THRESHOLD if more than 50,000 particles */
int long_switch=1;
int threshold;
char output_file[30]="particle_out_";//prefix for output file
char FILE_NAME[30];
/*define the structure that will hold all of the particle information*/
struct particles {
  double x; //x-coord
  double y;//y-coord
  double z;//z-coord
  double v_x;// x component of velocity
  double v_y;//y component of velocity
  double v_z;//z component of velocity
  double m;//mass of particle
  double q;//charge of particle
  double a_x;//x-acceleration
  double a_y;//y-acceleration
  double a_z;//z-acceleration
};


/******************************************
 **Func: The RK aux. function that specifies all of the physics
 **      Takes in the time, the variables y and the parameters
 **      y[ ]={x,v_x, y, v_y, z, v_z}
 **      derivs[ ]={dxdt, d2xdt2, dydt, d2ydt2, dzdt, d2zdt2}
 ******************************************/
int func (double t, const double y[], double derivs[], void *params)
{
  double* constants= *(double **)params;//{q/m,B_X,B_Y,B_Z}
  // printf("%lf, %lf, %lf, %lf\n",constants[0],constants[1], constants[2], constants[3]);//debug
 
 /*Set all of the v_x and dxdt's equal to each other (to make it into coupled first orders*/
  derivs[0]=y[1];
  derivs[2]=y[3]; 
  derivs[4]=y[5]; 
 
  derivs[1]=constants[0]*(constants[3]*y[3]-constants[2]*y[5]); //d2xdt2=q/m*(B_z*v_y-B_y*v_z)
  derivs[3]=constants[0]*(constants[1]*y[1]-constants[3]*y[1]); //d2ydt2=q/m*(B_x*v_z-B_z*v_x)
  derivs[5]=constants[0]*(constants[2]*y[1]-constants[1]*y[3]); //d2zdt2=q/m*(B_y*v_x-B_x*v_y)

  return GSL_SUCCESS;
}

/**************************************
 ****       Main Function          ****
 **************************************/
int main(void)
{
  /*Collect number of particles, threshold, from user*/
  printf("How many particles would you like to simulate?: ");
  char line [20]; 
 fgets(line, sizeof(line),stdin);
 sscanf(line, "%lu",&total_coordinates);
 printf("Increment size?: ");
 fgets(line, sizeof(line), stdin);
 sscanf(line, "%d", &threshold);
 // printf("Particles: %lu, threshold: %d\n", total_coordinates, threshold);
  char* mode="w"; //specify file mode, write/append
  int append_switch=0;

  
/*Time how long this takes*/
  time_t start, end;
  double dif;
  time(&start);

 
  /*Account for Threshold loop*/
  total_total=total_coordinates;  
  long int original=total_total;
  if(total_coordinates>threshold){
    total_coordinates=threshold;
  }

  struct particles p[total_coordinates+1];//array of structures for data 
  
/*******************************************************************
 * MAIN LOOP********************************************************
 *          ********************************************************
 *******************************************************************/
  while(long_switch==1){//while there are still particles left to generate
    printf("particles left=%lu\n",total_total);
    /*Account for Threshold*/
    if(total_total>=threshold){
      total_coordinates=threshold;
      total_total=total_total-threshold;}
    else{
      total_coordinates=total_total;
      long_switch=0;
    }
    if(append_switch==1)
      mode="a";
    else{
      mode="w";
      append_switch=1;
    }
    //printf("mode: %s\n",mode);
    /*************************************************
     *****Initial Parameters:*************************
     ************** x,y,z=0
     ************** v=init_v
     ************** theta, phi, gaussian from 0 to 2pi
     *************************************************/
    
    /*initialize the random number generator, seed it with the time*/
    const gsl_rng* rng=gsl_rng_alloc(gsl_rng_taus2);
    gsl_rng_set (rng, (unsigned long int) time(NULL));
    
    int i; //coordinate counter
    
    double p_phi[total_coordinates+1], p_theta[total_coordinates+1];
  
    /*Open 0 s file to write initial coordinates to*/
    char time_string[9];
    sprintf(time_string, "%1.4d.txt",0);
    strcpy(FILE_NAME, output_file);
    strcat(FILE_NAME, time_string);
 
    FILE*current_file=fopen(FILE_NAME,mode);
    // printf("filename: %s\n",FILE_NAME);
    if(current_file==NULL){
      printf("Error opening file %s\n",FILE_NAME);
      return(0); 
    }
  /*Fill the x and y arrays with uniform random numbers*/
    for(i=0; i<=total_coordinates; i++){
      p_theta[i]=gsl_ran_gaussian(rng, sigma);
      /* Cut off the tails of the Theta Gaussian */
      while(fabs(p_theta[i])>M_PI){
	p_theta[i]=gsl_ran_gaussian(rng, sigma); 
      } 
      p_phi[i]=gsl_ran_flat(rng,0,M_PI*2.0);
      p[i].v_z=init_v*cos(p_theta[i]);
      p[i].v_y=init_v*sin(p_theta[i])*cos(p_phi[i]);
      p[i].v_x=init_v*sin(p_theta[i])*sin(p_phi[i]);
      p[i].x=0.;
      p[i].y=0.;
      p[i].z=0.;
      p[i].m=m_e;
      p[i].q=e;
      p[i].a_x=0.0;
      p[i].a_y=0.0;
      p[i].a_z=0.0;
      fprintf(current_file, "%lf, %lf, %lf, %lf, %lf, %lf\n", p[i].x, p[i].y, p[i].z, p[i].v_x,p[i].v_y, p[i].v_z);
    }
    fclose(current_file);
    
    // printf("Past the number generation\n");
    /*********************************
     *** Start RK Stepping         ***
     *********************************/
    
    /*Set the physical constants*/
    double q_m=e/m_e;
    double const_array[]={q_m,B_X, B_Y, B_Z};
    double* constants=const_array;
    
    /*Setup the RK solver*/
    void *jac=NULL;//not using jacobian
    const gsl_odeiv_step_type* T = gsl_odeiv_step_rk4;//set the solver to RK-4
    gsl_odeiv_system sys = {func, jac, dimensions, &constants};  
    
    
    int t, step;//t is for seconds, step is for counting steps between seconds
    double t_h;//for the smaller steps
    double input[]={0.0,0.0,0.0,0.0,0.0,0.0};//declare the input array
    double y_err[dimensions-1];//output error
    double dydt_in[dimensions-1], dydt_out[dimensions-1];//input and output derivs
  
    /***********************
     **Main RK solver Loop**
     ***********************/
    
    for(t=0; t<=total_time; t++){
      /*Open File for this second*/
      sprintf(time_string, "%1.4d.txt",t+1);
      strcpy(FILE_NAME, output_file);
      strcat(FILE_NAME, time_string);
      //printf("filename: %s\n",FILE_NAME);
      FILE*current_file=fopen(FILE_NAME,mode);
      if(current_file==NULL){
	printf("Error opening file %s\n",FILE_NAME);
	return(0); 
      }
      //printf("t=%d\n",t);
      /*Loop through coordinates*/
      for (i=0; i<=total_coordinates;i++){
	t_h=t;
	gsl_odeiv_step * s = gsl_odeiv_step_alloc (T, dimensions);//allocate the solver  
	//	GSL_ODEIV_FN_EVAL(&sys, t_h, input, dydt_in); 
	// 	printf("i=%d\n",i);
	for(step=0;step<=(1/h);step++){
	  
	  input[0]=p[i].x;
	  input[1]=p[i].v_x;
	  input[2]=p[i].y;
	  input[3]=p[i].v_y;
	  input[4]=p[i].z;
	  input[5]=p[i].v_z;
	  dydt_in[0]=p[i].v_x;
	  dydt_in[1]=p[i].a_x;
	  dydt_in[2]=p[i].v_y;
	  dydt_in[3]=p[i].a_y;
	  dydt_in[4]=p[i].v_z;
	  dydt_in[5]=p[i].a_z;
	  int status = gsl_odeiv_step_apply (s, t_h, h, input, y_err, dydt_in,dydt_out, &sys);
	  p[i].x=input[0];
	  p[i].v_x=input[1];
	  p[i].y=input[2];
	  p[i].v_y=input[3];
	  p[i].z=input[4];
	  p[i].v_z=input[5];
	  p[i].a_x=dydt_out[1];
	  p[i].a_y=dydt_out[3];
	  p[i].a_z=dydt_out[5];
	  //  printf("t_h=%lf\n",t_h);
	  
	  
	  
	  t_h=t_h+h;//next time step
	}
	gsl_odeiv_step_free (s);
	/*print to file*/
	fprintf(current_file, "%lf, %lf, %lf, %lf, %lf, %lf\n", p[i].x, p[i].y, p[i].z, p[i].v_x,p[i].v_y, p[i].v_z);
	
	
      }
      
      
      fclose(current_file);
    }
    
  }
  
  
  
  time(&end);
  dif=difftime (end,start);
  printf("Total Particles: %lu, Runtime: %.8lf\n",original, dif);
  
  
  return(0);
}
