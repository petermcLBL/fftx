FFTX Project
============

This is the public repository for the FFTX API source, examples, and documentation.

## Prerequisites for installation

In order to install FFTX, you will need:
* **cmake**, version 3.14 or higher.
* if on Linux/Unix, **gcc** and **make**.
* if on Windows, **Visual Studio**,
and an ability to run **bash** shell scripts.  
You can use the Git Bash shell available with **git**,
but other shells such as Cygwin or msys will also work.
* if on macOS, version 10.14 (Mojave) or later of macOS,
with a compatible version of **Xcode** and **Xcode Command Line Tools**.
* **python**, version 3.6 or higher.  
On some systems, both **python** (usually version 2.7) and **python3** exist.
The scripts used to create the FFTX library source code check the
version of **python**, and if it is version 2.X
it will try to run **python3** instead.
A user, therefore, should not have to worry
whether **python** or **python3** comes first in the user's path.


## Building FFTX

To build FFTX, follow these steps:

1. [Install **SPIRAL** and associated packages.](#1-install-spiral-and-associated-packages)
2. [Clone the **FFTX** repo.](#2-clone-the-fftx-repo)
3. [Generate library source code.](#3-generate-library-source-code)
4. [Compile library source code and examples.](#4-compile-library-source-code-and-examples)

### 1. Install SPIRAL and associated packages

Clone **spiral-software** (available [**here**](https://www.github.com/spiral-software/spiral-software))
to a location on your computer.  For instance:
```
cd ~/work
git clone https://www.github.com/spiral-software/spiral-software
```
This location is known as *SPIRAL HOME*, and you must set an
environment variable **SPIRAL_HOME** (here, `~/work/spiral-software`)
to point to this location later.

Follow the build instructions for **spiral-software**
(see the **README** [**here**](https://github.com/spiral-software/spiral-software/blob/master/README.md)).  

**FFTX** requires the **SPIRAL** packages
[**fftx**](https://www.github.com/spiral-software/spiral-package-fftx),
[**simt**](https://www.github.com/spiral-software/spiral-package-simt), and
[**mpi**](https://www.github.com/spiral-software/spiral-package-mpi).
You need to download these separately, as follows:
```
cd $SPIRAL_HOME/namespaces/packages
git clone https://www.github.com/spiral-software/spiral-package-fftx fftx
git clone https://www.github.com/spiral-software/spiral-package-simt simt
git clone https://www.github.com/spiral-software/spiral-package-mpi mpi
```
**NOTE:** The **SPIRAL** packages must be installed
under directory **$SPIRAL_HOME/namespaces/packages**
and must be placed in folders with the
prefix *spiral-package-* removed. 


### 2. Clone the FFTX repo.

Clone **FFTX** to a location on your computer.  For instance:
```
cd ~/work
git clone https://www.github.com/spiral-software/fftx
```

Set the environment variable **FFTX_HOME** to point to the directory where
you will install **FFTX**
(which is not necessarily the same directory where you have
cloned **FFTX**; you may want to have separate installation directories
for different backends).

### 3. Generate library source code.

FFTX builds libraries of transforms for a set of different sizes.
The library source code is generated from **SPIRAL** script specifications,
and must be created before building FFTX itself.

Before creating the library source code, consider if you will be
running on CPU only, or also utilizing a GPU.
If you create all the source code (and related **cmake** scripts
and library APIs) for GPU and then try building
for CPU only, you may encounter compiler errors or unexpected results.

These instructions are for 
building on Linux or Linux-like systems.
On Windows, use a **bash** shell as mentioned under Prerequisites above.

The shell script `src/library/build-lib-code.sh`
generates the library source code.
The script takes one optional argument to specify what code to build.
Serial code (CPU) is always built.
GPU code is built when the argument passed is either **CUDA** or **HIP**.
Serial code is built if no argument is given or if the argument is **CPU**.

Make sure that the environment variable **SPIRAL_HOME** is set to
where you have cloned **spiral-software**.
Then from the directory where **FFTX** has been cloned,
switch to the `src/library` directory:
```
cd src/library
```
And then,
* if building for CPU only:
```
./build-lib-code.sh CPU
```
* if building for CUDA:
```
./build-lib-code.sh CUDA
```
* if building for HIP:
```
./build-lib-code.sh HIP
```

and switch back to the FFTX directory:
```
cd ../..
```

Running `build-lib-code.sh`
can take quite a long time depending on the number of transforms and
set of sizes to create.
The code is targeted to run on the CPU, and code is created targeted to
run on a GPU (CUDA or HIP) depending on the argument given
to the build script.
Depending on the number of sizes being built for each transform,
this process can take a considerable amount of time.

The text file `build-lib-code-failures.txt` will contain
a list of all library transforms that failed to be generated
in this step.

### 4. Compile library source code and examples.

If you are building on a supercomputing platform at NERSC or OLCF,
compilation requires having the appropriate modules loaded.

* #### On **cori** at NERSC:
```
module purge
module load cgpu cuda PrgEnv-gnu craype-haswell
```

* #### On **perlmutter** at NERSC:
```
module purge
module load cmake cudatoolkit PrgEnv-gnu 
export LIBRARY_PATH=$CUDATOOLKIT_HOME/../../math_libs/lib64
export CPATH=$CUDATOOLKIT_HOME/../../math_libs/include
```

* #### On **spock** at OLCF:
```
module purge
module load rocm
```

From your **FFTX** home directory, set up a **build** folder
(which can be given any name, and you may want to have separate
ones for different backends), and switch to it:
```
mkdir build
cd build
```
Then run **cmake** as follows.
* If building for CPU only:
```
cmake -DCMAKE_INSTALL_PREFIX=$FFTX_HOME -D_codegen=CPU ..
```
* If building for CUDA:
```
cmake -DCMAKE_INSTALL_PREFIX=$FFTX_HOME -D_codegen=CUDA ..
```
* If building for HIP:
```
cmake -DCMAKE_INSTALL_PREFIX=$FFTX_HOME -DCMAKE_CXX_COMPILER=hipcc -D_codegen=HIP ..
```

Now,
* if building on Linux:
```
make install
```
* if building on Windows:
```
cmake --build . --target install --config Release
```

And return to the FFTX directory:
```
cd ..
```

If you do not specify **CMAKE_INSTALL_PREFIX**
in the **cmake** command,
it often defaults to a system location,
such as `/usr/local`, to which you may not have write privileges;
thus it is best to specify **CMAKE_INSTALL_PREFIX** explicitly
on the **cmake** command line, as shown above.

When this step is done,  
* the folder **$FFTX_HOME/lib** will contain the libraries
that can be called by external applications;
* the folder **$FFTX_HOME/bin** will contain executables for the examples.

## Running FFTX example programs

After building,
to run the programs that are in the **examples** subtree, simply do:
```
cd $FFTX_HOME/bin
./testcompare_device
./testverify
```
etc. Since we set RPATH to point to where the libraries are installed,
you likely will not need to adjust the library path variable,
typically **LD_LIBRARY_PATH**.

See the README in the **examples** folder of this repo for the
list of examples, how to run them, and how to add a new example.

## Libraries

The libraries built and copied to the **$FFTX_HOME/lib** folder can be
used by external applications to leverage FFTX transforms.
To access the necessary include files
and libraries, an external application's **cmake** should include
**CMakeInclude/FFTXCmakeFunctions.cmake**.
A full example of an external
application linking with FFTX libraries is available in the
[**fftx-demo-extern-app**](https://www.github.com/spiral-software/fftx-demo-extern-app) repo.

### FFTX libraries built

**FFTX** builds libraries for 1D and 3D FFTs for a single device.
FFTs are built for a set of specific sizes, so not all possible sizes
will be found in the libraries.
The sizes to be built are listed in these two files:
* **src/library/cube-sizes.txt** for the 3D FFTs;
* **src/library/dftbatch-sizes.txt** for the 1D FFTs.

The following libraries are built:

|Type|Name|Description|Include Header File|
|:-----:|:-----|:-----|:-----:|
|3D FFT|fftx_mddft|Forward 3D FFT complex to complex |fftx_mddft_public.h|
|3D FFT|fftx_imddft|Inverse 3D FFT complex to complex |fftx_imddft_public.h|
|3D FFT|fftx_mdprdft|Forward 3D FFT real to complex |fftx_mdprdft_public.h|
|3D FFT|fftx_imdprdft|Inverse 3D FFT complex to real |fftx_imdprdft_public.h|
|3D Convolution|fftx_rconv|3D real convolution (in development) |fftx_rconv_public.h|
|1D FFT|fftx_dftbat|Forward batch of 1D FFT complex to complex|fftx_dftbat_public.h|
|1D FFT|fftx_idftbat|Inverse batch of 1D FFT complex to complex|fftx_idftbat_public.h|
|1D FFT|fftx_prdftbat|Forward batch of 1D FFT real to complex|fftx_prdftbat_public.h|
|1D FFT|fftx_iprdftbat|Inverse batch of 1D FFT complex to real|fftx_iprdftbat_public.h|

### Library API

Each library has serial code (CPU) and optionally GPU code (assuming either
CUDA or HIP code was built when the libraries were generated).
There are API calls to do the following:
* Determine (get) the mode for the library (serial or GPU).
* Specify (set) whether the library should operate in serial or GPU mode.
* Get the list of sizes built in the library.
* Get a tuple containing pointers to the init, destroy, and run
functions for a particular size.
* Run a specific size transform once.

The following example shows usage of the 3D FFT complex-to-complex transform
(others are similar; just use the appropriate names and header file(s) from the
table above).  The user (calling application) is responsible for setting up
memory buffers and allocations as required (i.e., host memory for serial code,
device memory for GPU code).

```
#include "fftx3.hpp"
#include "fftx_mddft_public.h"

    int libmode = fftx_mddft_GetLibraryMode ();   // get the library mode
    fftx_mddft_SetLibraryMode ( LIB_MODE_CUDA );  // specify CUDA mode (default)
    
    fftx::point_t<3> *wcube, curr;
    wcube = fftx_mddft_QuerySizes ();             // Get a list of sizes in library

    transformTuple_t *tupl;
    for ( int iloop = 0; ; iloop++ ) {
        if ( wcube[iloop].x[0] == 0 ) break;      // last entry in list is zero
        tupl = fftx_mddft_Tuple ( wcube[iloop] );

        ( * tupl->initfp )();                    // init function for transform

        ( * tupl->runfp )( outbuf, input, symbol );  // run the transform (may call multiple times)

        ( * tupl->destroyfp )();
    }
```
The available library modes
are `LIB_MODE_CPU`, `LIB_MODE_CUDA`, and `LIB_MODE_HIP`
for CPU, CUDA on GPU, and HIP on GPU, respectively.

### Linking against FFTX libraries

FFTX provides a **cmake** include file, **FFTXCmakeFunctions.cmake**, that
provides functions to facilitate compiling and linking external applications
with the FFTX libraries.
An external application should include this file
(**$FFTX_HOME/CMakeIncludes/FFTXCmakeFunctions.cmake**)
in order to access the following helper functions to compile/link
with the FFTX libraries.  Two functions are available:

1.  **FFTX_find_libraries**() : this function finds the FFTX libraries, linker
library path, and include file paths, and sets the following variables:

|CMake Variable Name|Description|
|:-----|:-----|
|**FFTX_LIB_INCLUDE_PATHS**|Include paths for FFTX include & library headers|
|**FFTX_LIB_NAMES**|List of FFTX libraries|
|**FFTX_LIB_LIBRARY_PATH**|Path to libraries (for linker)|

2.  **FFTX_add_includes_libs_to_target** ( target ) : this function adds the
include file paths, the linker library path, and the library names to the
specified target.

An application will typically need only call
**FFTX_add_includes_libs_to_target**(),
and let FFTX handle the assignment of paths, etc. to the target.
Only if an application specifically needs to access the named
variables above is it necessary to call **FFTX_find_libraries**().

### External application linking with FFTX

A complete example of an external application that builds test programs
utilizing the FFTX libraries is available at 
[**fftx-demo-extern-app**](https://www.github.com/spiral-software/fftx-demo-extern-app).
If you're interested in how to link an external application with FFTX please
download this example and review the `CMakeLists.txt` therein for specific
details.

When FFTX is built, the final step (of *make install*) creates and
populates a tree structure within **$FFTX_HOME**:

|Directory Name|Description|
|:-----|:-----|
|**./CMakeIncludes**|CMake include files and functions to ease integration with FFTX|
|**./bin**|Example programs built as part of the FFTX distribution|
|**./lib**|FFTX libraries|
|**./include**|Include files for using FFTX libraries|
