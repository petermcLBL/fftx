### How To Add A New Example

To add a new example to **FFTX**:
1. Create a folder in **fftx/examples**, called *project*.
2. In the newly created *project* folder, add your transform
definition(s), named *prefix*.**fftx.cpp**.
3. In the *project* folder, add a test harness named **test**_project_,
with either, or both, suffixes: **.cpp**, or **.cu**.
4. In the *project* folder, add (or copy and edit)
a **CMakeLists.txt** file (instructions for editing below).

### Setting Up The cmake File

The **cmake** file, **CMakeLists.txt**, has a section in the beginning to
specify a few names;
most of the rules and targets are defined automatically,
and few, if any, changes should be required.

The **cmake** file uses the variable **\_codegen**
setting of either CPU or CUDA or HIP
to determine whether to build, respectively, for CPU, or CUDA on GPU,
or HIP on GPU.
The variable **\_codegen** is defined
on the **cmake** command line (or defaults to CPU);
do *not* override it in the **cmake** file.

**1.** Set the project name.  The preferred name is
the same name as the example folder, e.g., **mddft**
```
project ( mddft ${_lang_add} ${_lang_base} )
```

**2.** As noted above, the file naming convention for the
*driver* programs is *prefix.stem*.**cpp**.
Specify the *stem* and *prefix(es)* used; e.g., from the **mddft** example:
```
set ( _stem fftx )
set ( _prefixes mddft imddft )
```

**3.** Check the test harness program name.
You won't need to modify this if you've followed the recommended conventions.
The test harness program name is expected to be **test**_*project*:
```
    set ( BUILD_PROGRAM test${PROJECT_NAME} )
```

Finally, add an entry to the **CMakeLists.txt** file in
the **examples** folder.
We use a **cmake** function, **manage_add_subdir,** to control this.
Call the function with parameters:
example directory name and TRUE/FALSE flags for building for CPU and GPU, as in:
```
##                  subdir name   CPU       GPU
manage_add_subdir ( hockney       TRUE      FALSE )
manage_add_subdir ( mddft         TRUE      TRUE  )
```
