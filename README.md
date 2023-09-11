Postmodern CMake was an experiment in adopting a Blaze-derived pattern for
defining CMake targets. We thought it was a pretty successful first effort.

It's also a joke. Because "Modern CMake" was picking up some well deserved steam
when we were authoring this. And I thought a literary pun would make for a good
library name. (And jokes are always funnier explained.)

### Using the library

The short of it is,
1. `include(postmodern_cmake)` as a module (modifying `CMAKE_MODULE_PATH` as
   necessary) in your CMakeLists.txt file.  
   Bonus points if you also `include(postmodern_cmake.test)`.
2. Author a set of `targets.cmake` files. Basically every directory that
   contains compilable code should contain a targets.cmake.
3. Define one or more target per `targets.cmake` file with the `pm_autotarget`
   (or `pm_target`) function.
4. Add `pm_parse_targets` to your CMakeLists.txt to Find and parse the
   targets.cmake file set. This function will recursively search the given
   directory for targets.cmake files, and `include` each of them as a means
   to load the defined targets into the current project.

If you'd like to start digging into the guts of this library, you should start
with pm_autotargets.cmake first, then pm_parse_arguments.cmake. It flows from
there. As much as a CMake library "flows," anyway.

For an example of this library in action, take a look at
https://github.com/ludumipsum/nonstd.

### Did you say, `include(postmodern_cmake.test)`?

Yep. This library comes with tests. Implemented in CMake, no less.

To see those in action,
- `cd test_project`
- `cmake .`
- Note the `-- Running Postmodern ... suite` log lines

Or `include(postmodern_cmake.test)` in your own CMakeLists.txt file and burn ~.3
seconds running the tests as part of your own generation phase.

postmodern_cmake.test.cmake is just a runner so to see how the tests work, I'd
recommend starting with pm_fail.test.cmake, and then whatever set of unit tests
look interesting.
