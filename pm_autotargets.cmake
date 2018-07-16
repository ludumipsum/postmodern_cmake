include_guard(GLOBAL)

# Utility macros for locating and building from target list files
# ---------------------------------------------------------------
# This file defines the tools necessary to adopt a Blaze-derived pattern for
# defining CMake targets. This pattern asks users to,
#
#  1. Author a set of `targets.cmake` files. Basically every directory that
#     contains compilable code should contain a targets.cmake.
#  2. Define targets with the `pm_autotarget` function. Each targets.cmake file
#     should include at least one `pm_autotarget` (or `pm_target` invocation.
#  3. Find and parse the targets.cmake file set with the `pm_parse_targets`
#     (or similar) function. This function will recursively search the given
#     directory for targets.cmake files, and `include` each of them as a means
#     to load the defined targets into the current project.
#
# These tools -- and the conventions they facilitate -- are meant to encourage
# the definition and management of a large number of narrowly scoped targets,
# each with explicitly defined dependencies.
#
# A Note on Names:
#
# Targets defined by `pm_autotarget` will be named, at least in part, by the
# directory structure of the project in which they are defined. If we consider
# the file that invokes `pm_parse_targets` to be the project "root", the
# root-relative path of each `targets.cmake` file will be used to generate a
# target-name prefix. If no `NAME` argument is given to the `pm_atuotargets`
# invocation, the target name will be that prefix; otherwise, the `NAME`
# argument will be appended to the prefix to generate the full target name.
#
# For example, if a CMakeLists.txt file in `.../my_project` invokes
# `pm_parse_targets`, and `.../my_project/util/targets.cmake` defines
# `pm_autotarget(NAME demo ...)`, the final CMake target will be  named
# `util::demo`. If `.../my_project/util/samples/targets.cmake` defines a
# `pm_autotarget` that doesn't include a `NAME`, the CMake target will be named
# `util::samples`.
#
# This prefix forces an explicit mirroring between the directory structure of
# the codebase, and names of CMake targets defined within it. This binding
# ensures that target names are uniform, rarely collide, and are easily derived,
# and that knowing the name of a target is all that you need in order to track
# down the relevant code.
#
# A Note on a Choice that CMake Made that Negatively Impacts This System:
#
# Above, I used target names like `util::demo`. This follows the CMake naming
# convention for namespaced or imported libraries, and is the naming convention
# that we use when building dependency graphs. Such targets are, unfortunately,
# not "real" targets according to CMake, and so cannot be built through a
# command-line invocation. (Ex; `ninja util::demo` would error with an undefined
# target.) Each target is given a second name in this system that simply
# replaces the `::` separator with a `.` and is "real" in the eyes of CMake and
# build tools. Instead of running `ninja util::demo`, one should run
# `ninja util.demo`.
#
# TODO: There's a developer email chain that's relevant to this. I should go
# look that up, and provide the link...
#
# A Note on Automatically Generated Targets:
#
# In addition to the primary target generated by pm_autotarget, every
# subdirectory that includes one or more target may be given a special
# aggregate target. The `AGGREGATES` list argument accepts one or more strings
# (defaulting to `"all"`, and negated with `"_"`) that will depend on all
# targets in the given subdirectory, and all directories below it.

# For example, consider a `.../my_project/util/targets.cmake` that defines
# TargetA, and a `.../my_project/util/widgets/targets.cmake` that defines an
# unnamed target, TargetB, and TargetC. Four primary targets will be defined,
# `util.TargetA`, `util.widgets`, `util.widgets.TargetB`, and
# `util.widgets.TargetC`. In addition, building `util.widgets.all` would build
# TargetB and TargetC, and building `util.all` would build all four.


include(pm__core)
include(pm_fail)
include(pm_list)
include(pm_parse_arguments)
include(pm_targets)

function(pm_parse_targets)
    pm_parse_arguments(
        arguments
            RELATIVE_FROM
            IN
        argn ${ARGN}
    )

    pm_set_if_unset(RELATIVE_FROM ${CMAKE_CURRENT_LIST_DIR})
    pm_resolve_path(RELATIVE_FROM ${RELATIVE_FROM})
    pm_path_is_absolute(RELATIVE_FROM_IS_ABS "${RELATIVE_FROM}")
    if(NOT RELATIVE_FROM_IS_ABS)
        set(RELATIVE_FROM "${CMAKE_CURRENT_LIST_DIR}/${RELATIVE_FROM}")
    endif()

    pm_set_if_unset(IN ${CMAKE_CURRENT_LIST_DIR})
    pm_resolve_path(IN ${IN})
    pm_path_is_absolute(IN_IS_ABS "${IN}")
    if(NOT IN_IS_ABS)
        set(IN "${CMAKE_CURRENT_LIST_DIR}/${IN}")
    endif()

    pm_status("target discovery: Searching for targets in ${IN}")

    file(GLOB_RECURSE TARGET_FILES "${IN}*/targets.cmake")
    list(LENGTH TARGET_FILES COUNT)

    pm_status("target discovery: Parsing with root dir of ${RELATIVE_FROM}...")

    foreach(TARGET_FILE ${TARGET_FILES})
        file(RELATIVE_PATH RELATIVE_TARGET_FILE_PATH ${RELATIVE_FROM} ${TARGET_FILE})
        get_filename_component(RELATIVE_TARGET_PATH ${RELATIVE_TARGET_FILE_PATH} DIRECTORY)

        # Because we're including in-line, all variables set here will be
        # visible inside the included *.targets file and, from there, the
        # `pm_autotarget` function calls.
        set(PM_ATT_RELATIVE_TARGET_PATH ${RELATIVE_TARGET_PATH})
        set(PM_ATT_ABSOLUTE_ROOT ${RELATIVE_FROM})
        include(${TARGET_FILE})
    endforeach()

    pm_status("target discovery: Parsed ${COUNT} target files...")
    pm_status("target discovery: Searching for targets in ${IN} -- done")
endfunction()


function(pm_autotarget)
    pm_parse_arguments(
        options
            EXECUTABLE
            STATIC_LIBRARY
            DYNAMIC_LIBRARY
            HEADER_ONLY_LIBRARY
            INCLUDE_IN_DEFAULT_BUILD
        arguments
            NAME
            COMPONENT
            PM_PROPERTIES
        list_arguments
            AGGREGATES
            HEADERS
            PRIVATE_HEADERS
            SOURCES
            DEPENDS
            PRIVATE_DEPENDS
        argn ${ARGN}
    )

    pm_build_alias_name(FULL_NAME ${PM_ATT_RELATIVE_TARGET_PATH} ${NAME})
    pm_build_dotted_name(TARGET_NAME ${FULL_NAME})

    # If the target and alias names are identical, don't bother with an alias.
    if(${TARGET_NAME} STREQUAL ${FULL_NAME})
        set(FULL_NAME "")
    endif()

    pm_set_if_unset(AGGREGATES "all")

    pm_target(
        NAME ${TARGET_NAME}
        ALIASES ${FULL_NAME}

        ${EXECUTABLE}
        ${STATIC_LIBRARY}
        ${DYNAMIC_LIBRARY}
        ${HEADER_ONLY_LIBRARY}
        ${INCLUDE_IN_DEFAULT_BUILD}

        COMPONENT       ${COMPONENT}
        PM_PROPERTIES   ${PM_PROPERTIES}
        HEADERS         ${HEADERS}
        PRIVATE_HEADERS ${PRIVATE_HEADERS}
        SOURCES         ${SOURCES}
        DEPENDS         ${DEPENDS}
        PRIVATE_DEPENDS ${PRIVATE_DEPENDS}

        # Inferred target attributes
        ROOT    ${PM_ATT_ABSOLUTE_ROOT}
        PATH    ${PM_ATT_RELATIVE_TARGET_PATH}
        INCLUDE .
    )

    if(PM_PROPERTIES)
        set(${PM_PROPERTIES} ${${PM_PROPERTIES}} PARENT_SCOPE)
    endif()

    # Aggregate target handling; creation and dependance

    # Get the list of directories whose aggregate targets the new target should
    # be added to. Note that if a NAME was not passed, the new target will be
    # named for the final directory, and should not be added to that
    # directory's aggregate. (ex; `.../util/demos/targets.cmake` only defines
    # `util.demos`. `util.demos.all` is redundant.)
    pm_path_to_list(TARGET_PATH_LIST ${PM_ATT_RELATIVE_TARGET_PATH})
    if(NOT DEFINED NAME)
        pm_list(POP_BACK TARGET_PATH_LIST _)
    endif()

    set(PATH_AGGREGATE)
    foreach(PATH IN LISTS TARGET_PATH_LIST)
        set(PATH_AGGREGATE ${PATH_AGGREGATE} ${PATH})
        foreach(AGGREGATE IN LISTS AGGREGATES)
            if(AGGREGATE STREQUAL "_")
                continue()
            endif()

            set(AGGREGATE_TARGET ${PATH_AGGREGATE} ${AGGREGATE})
            pm_list(JOIN AGGREGATE_TARGET AGGREGATE_TARGET ".")

            if(NOT TARGET ${AGGREGATE_TARGET})
                add_custom_target(${AGGREGATE_TARGET})
            endif()

            add_dependencies(${AGGREGATE_TARGET} ${TARGET_NAME})
        endforeach()
    endforeach()
endfunction()


# Compute a directory-structure-based alias for this target.
# For example, if we were building `pm_autotarget(NAME counter_test ...)`
# defined in `game/counter/test/targets.cmake` we'd calculate the alias name
# `gamelib::counter::test::counter_test`
function(pm_build_alias_name OUT PATH)
    pm_path_to_list(PATH_LIST ${PATH})
    set(PATH_LIST ${PATH_LIST} ${ARGN})
    string(REGEX REPLACE ";" "::" ALIAS_NAME "${PATH_LIST}")
    set(${OUT} ${ALIAS_NAME} PARENT_SCOPE)
endfunction()

# Compute a CMake-friendly dotted name from an alias. For example, if we have
# calculated the alias `gamelib::counter::test::counter_test`, we would use
# `gamelib.counter.test.counter_test` as a target.
function(pm_build_dotted_name OUT ALIAS_NAME)
    string(REGEX REPLACE "::" "." DOTTED_NAME ${ALIAS_NAME})
    set(${OUT} ${DOTTED_NAME} PARENT_SCOPE)
endfunction()
