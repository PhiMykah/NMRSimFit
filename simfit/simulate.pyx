import numpy as np
from libc.math cimport cos, sin, exp

# Cython compile time import
cimport numpy as np

# Import array used if any part of the
# numpy PyArray_* API is used.
np.import_array()

#############
# CONSTANTS #
#############

cdef float PI = np.pi
# Create static datatype for numpy array
DTYPE = np.float32  
DTYPE_COMPLEX = np.complex64
# Compile time type definition 
ctypedef np.complex64_t DTYPE_COMPLEX_t
ctypedef np.float32_t DTYPE_t
cdef int useNewLB = 1

# int sim1DE( rdata, idata, tsize, fsize, ctsize, x0, xfw, cosJVals, cosJCount, sinJVals, sinJCount, hi, p0, p1, useTimeScale, useTDDecay, useTDJMod )
# /***/
# /* Freq coord x0 is interpreted in range of 1 to fsize.
# /* Zero frequency in points 1->fsize is 1 + fsize/2.
# /* Create time domain data of length tsize.
# /* Compute total intensity of decay function.
# /***/
cpdef int sim1DE(
    np.ndarray[DTYPE_COMPLEX_t] data, int tsize, int fsize, 
    int ctsize, float x0, float xfw,
    np.ndarray[DTYPE_t] cosJVals, int cosJCount, 
    np.ndarray[DTYPE_t] sinJVals, int sinJCount,
    float hi, float p0, float p1, 
    int useTimeScale, int useTDDecay, int useTDJMod
    ):

    cdef float freq, tR, tI, f, q, lb, sum, amp, phi, delay
    cdef int ix, j

    cdef float[:] dataReal = data.real
    cdef float[:] dataImag = data.imag

    # Ensure nonzero xfw
    xfw = np.abs(xfw)

    # Set every negative ctsize to 0
    ctsize = 0 if ctsize < 0 else ctsize

    # Cap ctsize to tsize
    ctsize = tsize if (ctsize > tsize) else ctsize

    freq = 2.0*PI*(x0 - (1 + fsize/2))/(fsize)

    if useNewLB:
        lb = -0.5*xfw*PI/tsize if useTDDecay else -xfw*PI/fsize
    else:
        lb = -xfw/tsize if useTDDecay else -xfw*PI/fsize

    sum = 0

    delay = p1/360.0
    phi = PI*(p0 + p1/2.0)/180

    # Starting loop
    # -------------

    if (ctsize):
        for ix in range(ctsize):
            amp = 1.0
            f   = phi + (delay + ix) * freq
            dataReal[ix] =  hi * amp * cos(f)
            dataImag[ix] = -hi * amp * sin(f)
            sum = sum + amp

        for ix in range(ctsize, tsize):
            amp = exp( (1 + ix - ctsize) * lb)
            f   = phi + (delay + ix)*freq
            dataReal[ix] =  hi * amp * cos(f)
            dataImag[ix] = -hi * amp * sin(f)
            sum = sum + amp
    else:
        for ix in range(tsize):
            amp = exp(ix * lb)
            f   = phi + (delay + ix) * freq
            dataReal[ix] =  hi * amp * cos(f)
            dataImag[ix] = -hi * amp * sin(f)
            sum = sum + amp
        pass

    
    # Apply Couplings if any
    # ----------------------

    for j in range(cosJCount):
        q = PI*cosJVals[j]/(tsize - 1) if useTDJMod else PI*cosJVals[j]/(fsize - 1)

        for ix in range(tsize):
            amp = cos( q * ix )
            dataReal[ix] = dataReal[ix] * amp
            dataImag[ix] = dataImag[ix] * amp
    
    for j in range(sinJCount):
        q = PI*sinJVals[j]/(tsize - 1) if useTDJMod else PI*sinJVals[j]/(fsize - 1)

        for ix in range(tsize):
            amp = sin( q * ix )
            dataReal[ix] = dataImag[ix] * amp
            dataImag[ix] = -dataReal[ix] * amp

    # Scale the FID by decay-sum to give desired height after FT
    # ----------------------------------------------------------

    sum = sum / tsize

    
    if (not useTimeScale or (sum == 0)):
        return 0

    amp = 1 / sum

    for ix in range(tsize):
        dataReal[ix] = dataReal[ix] * amp
        dataImag[ix] = dataImag[ix] * amp

    return 0