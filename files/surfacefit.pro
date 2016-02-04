; David Rodriguez
; Aug 13, 2003
; Surface Fit
; This program will fit a flat surface to a set of 3D data
; it will return coefficients, chi squared, and uncertainties for the coefficients

PRO surfacefit, x, y, z, coeff, uncer, chi, stdz

ON_ERROR, 1

;Evaluate sums
sumx = TOTAL(x)
sumy = TOTAL(y)
sumz = TOTAL(z)
sumxy = TOTAL(x*y)
sumxz = TOTAL(x*z)
sumyz = TOTAL(y*z)
sumx2 = TOTAL(x^2)
sumy2 = TOTAL(y^2)
N = N_ELEMENTS(z)

;Evaluate Determinants
d1 = DETERM( [ [sumy2, sumxy], [sumxy, sumx2] ] )
d2 = DETERM( [ [sumy,  sumxy], [sumx,  sumx2] ] )
d3 = DETERM( [ [sumy,  sumy2], [sumx,  sumxy] ] )
mi = N*d1 - sumy*d2 + sumx*d3
d4 = DETERM( [ [   N,  sumx ], [sumx,  sumx2] ] )
d5 = DETERM( [ [   N,  sumx ], [sumy,  sumxy] ] )
d6 = DETERM( [ [   N,  sumy ], [sumx,  sumxy] ] )
d7 = DETERM( [ [   N,  sumy ], [sumy,  sumy2] ] )

;The coefficients
A = ( sumz*d1 - sumyz*d2 + sumxz*d3) / mi
B = (-sumz*d2 + sumyz*d4 - sumxz*d5) / mi
C = ( sumz*d3 - sumyz*d6 + sumxz*d7) / mi

coeff = FINDGEN(3)
coeff[0] = A
coeff[1] = B
coeff[2] = C

;The uncertainties
zfit = A+B*y+C*x
stdz = SQRT( TOTAL( (z - zfit)^2 ) / (N-3) )
chi = TOTAL( (z - zfit)^2 / zfit )

sumda2 = (N*d1^2 + sumy2*d2^2 + sumx2*d3^2 + 2*(sumx*d1*d3 - sumy*d1*d2 - sumxy*d2*d3) ) / mi^2
sumdb2 = (N*d2^2 + sumy2*d4^2 + sumx2*d5^2 + 2*(sumx*d2*d5 - sumy*d2*d4 - sumxy*d4*d5) ) / mi^2
sumdc2 = (N*d3^2 + sumy2*d6^2 + sumx2*d7^2 + 2*(sumx*d3*d7 - sumy*d3*d6 - sumxy*d6*d7) ) / mi^2

stda = stdz * SQRT(sumda2)
stdb = stdz * SQRT(sumdb2)
stdc = stdz * SQRT(sumdc2)

uncer = FINDGEN(3)
uncer[0] = stda
uncer[1] = stdb
uncer[2] = stdc

;Print out values
PRINT, 'For z = A + B*y + C*x'
PRINT, 'A = ', A, ' +/- ', stda
PRINT, 'B = ', B, ' +/- ', stdb
PRINT, 'C = ', C, ' +/- ', stdc
PRINT, 'Sum of differences squared: ', TOTAL( (z - zfit)^2 )
PRINT, 'Uncertainty in z: ', stdz
PRINT, "Chi Squared: ", chi
PRINT, 'Number of terms: ', N
PRINT, 'Parameters: 3   ', '  Degrees of freedom: ', N-3
PRINT, 'Reduced Chi Squared: ', chi / (N-3)


END