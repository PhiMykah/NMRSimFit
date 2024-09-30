from simfit.hello import say_hello_to
from simfit.simulate import sim1DE
import numpy as np

def main() -> int:
    say_hello_to("user")
    tsize : int     = 512
    fsize : int     = 1024
    ctsize : int    = 0
    x0 : float      = 500
    xfw : float     = 4
    cosJCount : int = 0
    sinJCount : int = 0
    hi : float      = 100 
    p0 : float      = 0
    p1 : float      = 0
    useTimeScale : bool = False
    useTDDecay : bool = False
    useTDJMod : bool = False
    
    data : np.ndarray = np.zeros(tsize, dtype=np.complex64)
    cosJVals : np.ndarray = np.zeros(cosJCount, dtype=np.float32)
    sinJVals : np.ndarray = np.zeros(sinJCount, dtype=np.float32)

    error : int = 0

    print(data)

    print("Processing....\n\n\n\n")

    error = sim1DE(data, tsize, fsize, ctsize, x0, xfw,
           cosJVals, cosJCount, sinJVals, sinJCount,
           hi, p0, p1, useTimeScale, useTDDecay, useTDJMod)

    if error != 0:
        print("An error has occured.")

    print(data)

if __name__ == '__main__':
    main()