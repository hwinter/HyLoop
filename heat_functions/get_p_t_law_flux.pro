
;flux=get_p_t_law_flux(1d9, 0.0,1d6)
function  get_p_t_law_flux, length, alpha,Tmax, $
  GAMMA=GAMMA, KAPPA=KAPPA, LAMBDA=LAMBDA, $
  MU=MU, NU=NU,SIGMA=SIGMA, BETA_LAMBDA=BETA_LAMBDA, $
  BETA_SIGMA=BETA_SIGMA

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

if size(length,/TYPE) eq 0 then length=1d9
if size(alpha,/TYPE) eq 0 then alpha=0d
if size(Tmax,/TYPE) eq 0 then Tmax=1d6
;Index for the power law heating function.[Dimensionless]
if not keyword_set(GAMMA) then GAMMA=5d-1;
;Spitzer Conductivity constant [erg cm^-1 K^-1]
if not keyword_set(KAPPA) then KAPPA=1.1d-6
;Have to figure out a better way
alpha_in=alpha
alpha_in>=-2.4

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Define parameters based on Martens, 2008
mu=-(2d0+GAMMA)/3.5d0
nu=alpha_in/3.5d0

lambda=(1d0-2d0*nu+mu)/(2d0*(nu-mu))
sigma=lambda+ $
      alpha_in/(alpha_in+gamma+2)

;Incomplete Beta functions.
beta_lambda=beta(lambda+1d0, 5d-1,/DOUBLE)
beta_sigma=beta(sigma+1d0, 5d-1,/DOUBLE)

F_alpha=(Tmax^(3.5d0))* $
        (kappa/length)* $
        ((3.5d0+alpha_in)*beta_lambda*beta_sigma)/ $
        (4d0*(2d0+gamma)^2d0)
        
;stop
return, F_alpha



END
