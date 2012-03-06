/* Brian Larsen */
/* balarsen <at> bu <dot> edu */
/* 4 April 2008 */
/* gsl_sobol.c */
/* This is a wrapper roounte to bridge between IDL and the GSL sobol sequence generator. */

/* One might ask why the bridge is needed and the answer is that you have to make N 
calls to the GSL routine to generate N sobol numbers.  This bridge means one call
 from IDL to C and then N calls C to C which is fast. */

/* One needs to have GSL installed and in the path.  In the same directory as this
 you need gsl_sobol.pro and a copy of idl_export.h */

/* Good luck, I wrote this on a MAC 10.5.2 and have no idea if it works elsewhere. */


#include <stdio.h>
#include <gsl/gsl_qrng.h>
#include "idl_export.h"         /* IDL external definitions */       

void gsl_sobol(IDL_LONG num, double arr[], short dims)
{
  long i;
  double v[dims];
  gsl_qrng * q = gsl_qrng_alloc (gsl_qrng_sobol, dims);
  

  for (i = 0; i < num; i++)
    {
  gsl_qrng_get (q, v);      

  // there has to be a better way, but I could not find it... ugly, yuk
  arr[i] = v[0];
  if (dims > 1) {
    arr[i+1*num]=v[1];
  if (dims > 2) {
    arr[i+2*num]=v[2];
  if (dims > 3) {
    arr[i+3*num]=v[3];
  if (dims > 4) {
    arr[i+4*num]=v[4];
  if (dims > 5) {
    arr[i+5*num]=v[5];
  if (dims > 6) {
    arr[i+6*num]=v[6];
  if (dims > 7) {
    arr[i+7*num]=v[7];
  if (dims > 8) {
    arr[i+8*num]=v[8];
  if (dims > 9) {
    arr[i+9*num]=v[9];
  if (dims > 10) {
    arr[i+10*num]=v[10];
  if (dims > 11) {
    arr[i+11*num]=v[11];
  if (dims > 12) {
    arr[i+12*num]=v[12];
  if (dims > 13) {
    arr[i+13*num]=v[13];
  if (dims > 14) {
    arr[i+14*num]=v[14];
  if (dims > 15) {
    arr[i+15*num]=v[15];
  if (dims > 16) {
    arr[i+16*num]=v[16];
  if (dims > 17) {
    arr[i+17*num]=v[17];
  if (dims > 18) {
    arr[i+18*num]=v[18];
  if (dims > 19) {
    arr[i+19*num]=v[19];
  if (dims > 20) {
    arr[i+20*num]=v[20];
  if (dims > 21) {
    arr[i+21*num]=v[21];
  if (dims > 22) {
    arr[i+22*num]=v[22];
  if (dims > 23) {
    arr[i+23*num]=v[23];
  if (dims > 24) {
    arr[i+24*num]=v[24];
  if (dims > 25) {
    arr[i+25*num]=v[25];
  if (dims > 26) {
    arr[i+26*num]=v[26];
  if (dims > 27) {
    arr[i+27*num]=v[27];
  if (dims > 28) {
    arr[i+28*num]=v[28];
  if (dims > 29) {
    arr[i+29*num]=v[29];
  if (dims > 30) {
    arr[i+30*num]=v[30];
  if (dims > 31) {
    arr[i+31*num]=v[31];
  if (dims > 32) {
    arr[i+32*num]=v[32];
  if (dims > 33) {
    arr[i+33*num]=v[33];
  if (dims > 34) {
    arr[i+34*num]=v[34];
  if (dims > 35) {
    arr[i+35*num]=v[35];
  if (dims > 36) {
    arr[i+36*num]=v[36];
  if (dims > 37) {
    arr[i+37*num]=v[37];
  if (dims > 38) {
    arr[i+38*num]=v[38];
  if (dims > 39) {
    arr[i+39*num]=v[39];
  if (dims > 40)
    arr[i+40*num]=v[40];
  }}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}
																				      																				      

    }  
  gsl_qrng_free (q);
}
