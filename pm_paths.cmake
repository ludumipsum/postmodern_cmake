include_guard(GLOBAL)

include(pm__core)


# CMake's `if(IS_ABSOLUTE)` has different semantics based on what platform
# you're on -- `C:/some/path` is not an absolute *nix path -- so this function
# provides a clean way to check for potential absolute-path-ness.
function(pm_path_is_absolute OUT PATH)
    if("${PATH}" MATCHES "^[A-Z]:/" OR "${PATH}" MATCHES "^/")
        set(${OUT} TRUE PARENT_SCOPE)
    else()
        set(${OUT} FALSE PARENT_SCOPE)
    endif()
endfunction()


# Since windows absolute roots are lettered drives, we can't just hardcode
# this to e.g. C:\ or we'll fall over on hosts where the build path isn't on
# the OS install disk. Instead we have to do a little bit of a dirty trick and
# assume that the build dir and source dir at least aren't on different drives,
# and we can recursively drop path elements starting wherever this cmakelists
# file is until we get to the last one, which will be the root.
function(pm_find_abs_root OUT PATH)
    pm_disallow_extra_args("pm_find_abs_root" ${ARGN})

    get_filename_component(dirent ${PATH} NAME)
    get_filename_component(rest ${PATH} DIRECTORY)

    set(root "")
    if ("${dirent}" STREQUAL "")
        set(root ${rest})
    else()
        pm_find_abs_root(root ${rest})
    endif()

    set(${OUT} ${root} PARENT_SCOPE)
endfunction()
pm_find_abs_root(PM_ABS_PATH_ROOT ${CMAKE_CURRENT_LIST_FILE})

# Collapses and normalizes a path; strips trailing `/`s, convert ex;
# `some/path/../thing` -> `some/thing`.
function(pm_resolve_path OUT PATH)
    pm_path_is_absolute(PATH_IS_ABS "${PATH}")
    if(PATH_IS_ABS)
        # For absolute paths, `get_filename_component(... ABSOLUTE)` does
        # exactly what we want.
        get_filename_component(OUT_ "${PATH}" ABSOLUTE)
    else()
        # Special-case paths that are exactly `.`; resolving such a path
        # results in an un-set variable.
        if(PATH STREQUAL ".")
            set(${OUT} "." PARENT_SCOPE)
            return()
        endif()
        # For relative paths, we use `file(RELATIVE_PATH)`, which expects two
        # absolute paths, and returns the intersection thereof. To make room for
        # paths that resolve to one or more upward moves (eg. `../..`) we tack
        # on 16 arbitrary directories to the platform-dependent root.
        # Note: This does mean you can't resolve a path that ends up being 17 or
        # more `../`s.
        # Note: If you think you need the above, I would recommend getting
        # kicked in the teeth.
        # Lastly we manually strip any trailing slashes with a regex.
        set(FALSE_ROOT ${PM_ABS_PATH_ROOT}0/1/2/3/4/5/6/7/8/9/a/b/c/d/e/f)
        file(RELATIVE_PATH OUT_ ${FALSE_ROOT} ${FALSE_ROOT}/${PATH})
        string(REGEX REPLACE "[/\\]$" "" OUT_ "${OUT_}")
    endif()
    set(${OUT} ${OUT_} PARENT_SCOPE)
endfunction()

# Recursively destructure paths to lists of dirents by spliting on the
# final element and collecting it in ${OUT_LIST}
function(pm_path_to_list OUT_LIST PATH)
    pm_disallow_extra_args("pm_path_to_list" ${ARGN})
    pm_resolve_path(path ${PATH})
    set(list ${${OUT_LIST}})

    get_filename_component(dirent ${path} NAME)
    get_filename_component(rest ${path} DIRECTORY)

    if ("${dirent}" STREQUAL "")
        # Aboslute paths leave the remainder in rest
        set(list ${rest} ${list})
    elseif("${rest}" STREQUAL "")
        # Relative paths leave the remainder in dirent
        set(list ${dirent} ${list})
    else()
        set(list ${dirent} ${list})
        pm_path_to_list(list ${rest})
    endif()

    set(${OUT_LIST} ${list} PARENT_SCOPE)
endfunction()
