include_guard(GLOBAL)

include(pm__core)
include(pm_paths)


function(pm_install_files)
    pm_parse_arguments(
        options
            INCLUDE_IN_DEFAULT_BUILD
        arguments
            PATH
            ROOT
            COMPONENT
            PREFIX
        list_arguments
            FILES
        argn ${ARGN}
    )

    pm_set_if_unset(ROOT "${CMAKE_CURRENT_LIST_DIR}")
    pm_set_if_unset(COMPONENT "library")
    pm_set_if_unset(PREFIX "include")

    # If the given files are not required to be part of the default build, we
    # need to mark them as OPTIONAL so `file(INSTALL)` calls don't blow up.
    if(NOT INCLUDE_IN_DEFAULT_BUILD)
        set(OPTIONAL OPTIONAL)
    endif()

    set(PATH_ABS ${ROOT}/${PATH})
    pm_resolve_path(PATH_ABS ${PATH_ABS})

    foreach(FILE_REL ${FILES})
        # Use the absolute file prefix to get the absolute path to the file.
        set(FILE_ABS ${PATH_ABS}/${FILE_REL})
        # Extract the directory component of FILE_REL, if any.
        get_filename_component(DIR_REL ${FILE_REL} DIRECTORY)
        # Use the PREFIX argument and DIR_REL to build a destination path,
        # normalizing with `pm_resolve_path`.
        set(DESTINATION ${PREFIX}/${DIR_REL})
        pm_resolve_path(DESTINATION ${DESTINATION})

        install(FILES ${FILE_ABS}
            DESTINATION ${DESTINATION}
            COMPONENT ${COMPONENT}
            ${OPTIONAL}
        )
    endforeach()
endfunction()
