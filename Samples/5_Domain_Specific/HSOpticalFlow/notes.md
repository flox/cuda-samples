# TODO
- add `-L` flag to `find` command for NixOS cuda support
- probably want to add `CUDA_HOME`="$FLOX_ENV" somewhere

# Notes
- The stubs are used at build time, real libraries used at runtime
- It uses dlopen to find the library at runtime because it's not shown in ldd output
- Because we recursively link all of the outputs, the stub outputs override the real libraries
- LD_LIBRARY_PATH=/run/opengl-driver/lib solves the problem

- `ld-floxlib` finds the libraries in FLOX_ENV, but those are the stubs
- it does know the correct paths though, so if you uninstall the stubs library, the package will run

- (on the v12.8 tag)
- This repo expects you to build against stubs, which requires the `cudart` package
	- This allows you to build against the toolkit and run against potentially different drivers.
- Fails at runtime because it loads the stubs from FLOX_ENV
- `ld-floxlib` knows where to find the drivers on the system, but are lower priority than libraries found in FLOX_ENV
- Setting LD_LIBRARY_PATH fixes the problem, because `ld-floxlib` is only run if the library isn't found in any other locations.
- Why is it looking for libraries in the environment at runtime?
	- Which variable is controlling that?

- The dynamic linker uses the RPATH to look for libcuda
- Program loads, uses `dlopen` to look for CUDA libraries in the environment (LD_LIBRARY_PATH)
- This is empty or doesn't contain those libraries
- `ld-floxlib` is called
	- Looks for libs in FLOX_ENV_DIRS <- stubs are found in here
	- Looks for libs in LD_FLOXLIB_DIRS_PATH
	- Looks for libs in LD_FLOXLIB_FILES_PATH <- system libraries are correctly found by 0800_cuda.sh and stored here

Running the built artifact with a run-mode activation *works*, but isn't *good*.
- At the core we have a runtime dependency that's different from the build time dependencies.


LD_DEBUG=libs ./program
fails at runtime without LD_LIBRARY_PATH=/run/opengl-driver/lib/

You can use `patchelf --add-rpath /run/opengl-driver/lib/` to modify the built binary

Move LD_FLOXLIB_FILES_PATH before the other two entries?
- Makes the most specific search path the highest priority
