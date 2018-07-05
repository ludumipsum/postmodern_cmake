include_guard(GLOBAL)

include(pm__core)
include(pm_fail)
include(pm_install_files)
include(pm_list)
include(pm_parse_arguments)
include(pm_paths)
include(pm_proplist)
include(pm_variable_group)


function(pm_include_all_targets_in_default_build)
    set(PM_ALL_TARGETS_IN_DEFAULT_BUILD TRUE PARENT_SCOPE)
endfunction()

# TODOs:
#   - `COMPONENT` feels like a CMake-ism. Can we do better? We're (probably)
#     only going to be using that argument for controlling installation, but I'm
#     not sure what a better name might be. Also, I'm not sure if we breaking
#     from CMake here would be super useful.
#   - Consider `HEADERS`, and `PUBLIC_HEADERS` v `PRIVATE_HEADERS`. Which do we
#     want to be explicit; the headers that get installed as part of an
#     installation, or the headers that don't? Which do we want to be the
#     default, and should that affect our usage?
#   - Usage docs.
function(pm_target)
    pm_parse_arguments(
        options
            EXECUTABLE
            STATIC_LIBRARY
            DYNAMIC_LIBRARY
            HEADER_ONLY_LIBRARY
            ALIAS
            INCLUDE_IN_DEFAULT_BUILD
        arguments
            NAME
            ROOT
            PATH
            INCLUDE
            COMPONENT
            BINARY_DEST
            INCLUDE_DEST
            LIBRARY_DEST
            PM_PROPERTIES
        list_arguments
            HEADERS
            PRIVATE_HEADERS
            SOURCES
            DEPENDS
            PRIVATE_DEPENDS
            ALIASES
        argn ${ARGN}
    )

    pm_variable_group(
        NAME
            TARGET_TYPES
        VARIABLES
            EXECUTABLE
            STATIC_LIBRARY
            DYNAMIC_LIBRARY
            HEADER_ONLY_LIBRARY
            ALIAS
        CAPTURE_TRUTHY_LIST
        CAPTURE_NUMBER_TRUTHY
    )
    pm_list(JOIN TARGET_TYPES_TRUTHY_LIST TARGET_TYPES_TRUTHY_STR ", ")

    # Argument Default Initialization
    # -------------------------------

    # If no target type was given, figure out what the best default would be.
    if(TARGET_TYPES_NUMBER_TRUTHY EQUAL 0)
        if(NOT SOURCES)
            set(HEADER_ONLY_LIBRARY TRUE)
        else()
            set(STATIC_LIBRARY TRUE)
        endif()
    endif()

    pm_set_if_unset(ROOT "${CMAKE_CURRENT_LIST_DIR}")
    pm_resolve_path(ROOT "${ROOT}")

    pm_resolve_path(PATH "${PATH}")

    pm_set_if_unset(INCLUDE "${PATH}")
    pm_resolve_path(INCLUDE "${INCLUDE}")

    pm_set_if_unset(COMPONENT "library")

    pm_set_if_unset(BINARY_DEST "bin")
    pm_set_if_unset(INCLUDE_DEST "include")
    pm_set_if_unset(LIBRARY_DEST "lib")

    # Argument Validation
    # -------------------

    pm_fail(
        IF_NOT_SET NAME
        WITH "pm_target: A NAME is required."
    )

    pm_fail(
        WHEN TARGET_TYPES_NUMBER_TRUTHY GREATER 1
        WITH "pm_target: The following options are mutually exclusive: ("
             "${TARGET_TYPES_TRUTHY_STR}). Please select only one target type "
             "for '${NAME}'."
    )

    pm_fail(
        WHEN_NOT IS_ABSOLUTE "${ROOT}"
        WITH "pm_target: `ROOT` must be an absolute path, for now at least. "
             "If you really think a relative path is correct, you will have "
             "to modify this function."
    )

    pm_fail(
        WHEN IS_ABSOLUTE "${PATH}"
        WITH "pm_target: `PATH` must be a relative path, for now at least. "
             "If you really think an absolute path is correct, you will have "
             "to modify this function."
    )

    pm_fail(
        WHEN IS_ABSOLUTE "${INCLUDE}"
        WITH "pm_target: `INCLUDE` must be a relative path, for now at least. "
             "If you really think an absolute path is correct, you will have "
             "to modify this function."
    )

    # Additional Variable Initialization
    # ----------------------------------

    # Build the correct absolute build and install interface include paths
    # based on the relative `INCLUDE` path.

    # Use `pm_resolve_path` in case the path includes `../`s.
    set(ABS_PATH_PREFIX ${ROOT}/${PATH})
    pm_resolve_path(ABS_PATH_PREFIX ${ABS_PATH_PREFIX})

    set(ABS_INCLUDE_DIR ${ROOT}/${INCLUDE})
    pm_resolve_path(ABS_INCLUDE_DIR ${ABS_INCLUDE_DIR})

    set(INSTALL_PATH_PREFIX ${INCLUDE_DEST}/${PATH})
    pm_resolve_path(INSTALL_PATH_PREFIX ${INSTALL_PATH_PREFIX})

    set(INSTALL_INCLUDE_DIR ${INCLUDE_DEST}/${INCLUDE})
    pm_resolve_path(INSTALL_INCLUDE_DIR ${INSTALL_INCLUDE_DIR})

    # Create a new set of file lists using the above paths. Note that the pubilc
    # headers are the only files that may need to be installed, so we can skip
    # the relative-path version of the other two file-list-types.
    pm_list(PREFIX_EACH HEADERS         OUTPUT HEADERS_ABS         "${ABS_PATH_PREFIX}/")
    pm_list(PREFIX_EACH PRIVATE_HEADERS OUTPUT PRIVATE_HEADERS_ABS "${ABS_PATH_PREFIX}/")
    pm_list(PREFIX_EACH SOURCES         OUTPUT SOURCES_ABS         "${ABS_PATH_PREFIX}/")

    pm_list(PREFIX_EACH HEADERS         OUTPUT HEADERS_INSTALL     "${INSTALL_PATH_PREFIX}/")

    # Define a default export name based on the given `COMPONENT`.
    pm_set_if_unset(EXPORT_NAME ${COMPONENT}-targets)

    # Define a LINK_MODE, in case we need to worry about library format.
    if(STATIC_LIBRARY)
        set(LINK_MODE STATIC)
    elseif(DYNAMIC_LIBRARY)
        set(LINK_MODE SHARED)
    endif()


    # Define a CMake Target
    # ---------------------

    if(HEADER_ONLY_LIBRARY)
        # Validation specifically for HEADER_ONLY_LIBRARY targets
        pm_fail(
            IF SOURCES
            WITH "pm_target: Header only libraries can't make sense of "
                 "source files."
        )
        pm_fail(
            IF PRIVATE_HEADERS
            WITH "pm_target: Header only libraries can't make sense of "
                 "private headers."
        )
        pm_fail(
            IF PRIVATE_DEPENDS
            WITH "pm_target: Header only libraries can't make sense of "
                 "privately dependencies."
        )

        # Marking the target as `INTERFACE` allows up to skip defining any
        # buildable components, and only track headers. It also _dramatically_
        # narrows the number of properties we can "correctly" set using CMake
        # functions, but hopefully we won't need to care about that.
        add_library(${NAME} INTERFACE)
        target_sources(${NAME} INTERFACE
            $<BUILD_INTERFACE:${HEADERS_ABS}>
            $<INSTALL_INTERFACE:${HEADERS_INSTALL}>
        )
        # TODO: Find out if we can drop the build_interface here. I assume we
        # need to define some kind of include directory, but...
        target_include_directories(${NAME} INTERFACE
            $<BUILD_INTERFACE:${ABS_INCLUDE_DIR}>
            $<INSTALL_INTERFACE:${INSTALL_INCLUDE_DIR}>
        )
        target_link_libraries(${NAME} INTERFACE ${DEPENDS})

        # Generate all alias names requested for the target
        foreach(ALIAS IN LISTS ALIASES)
            add_library(${ALIAS} ALIAS ${NAME})
        endforeach()

    elseif(STATIC_LIBRARY OR DYNAMIC_LIBRARY)
        add_library(${NAME} ${LINK_MODE} "")
        # TODO: See if we need to add build_ / install_ generator expressions to
        # the private target interactions.
        target_sources(${NAME} PRIVATE ${SOURCES_ABS})
        target_sources(${NAME} PUBLIC
            $<BUILD_INTERFACE:${HEADERS_ABS}>
            $<INSTALL_INTERFACE:${HEADERS_INSTALL}>
        )
        target_sources(${NAME} PRIVATE ${PRIVATE_HEADERS_ABS})
        target_link_libraries(${NAME} PUBLIC ${DEPENDS})
        target_link_libraries(${NAME} PRIVATE ${PRIVATE_DEPENDS})
        target_include_directories(${NAME} PUBLIC
            $<BUILD_INTERFACE:${ABS_INCLUDE_DIR}>
            $<INSTALL_INTERFACE:${INSTALL_INCLUDE_DIR}>
        )

        # Unless we've exploicitly marked this target or all targets for
        # inclusion in the default build, set EXCLUDE_FROM_ALL to TRUE.
        if(NOT (INCLUDE_IN_DEFAULT_BUILD OR PM_ALL_TARGETS_IN_DEFAULT_BUILD))
            pm_set_target_property(${NAME} EXCLUDE_FROM_ALL TRUE)
        endif()

        # Generate all alias names requested for the target
        foreach(ALIAS IN LISTS ALIASES)
            add_library(${ALIAS} ALIAS ${NAME})
        endforeach()

    elseif(EXECUTABLE)
        # Validation specifically for EXE targets
        if(HEADERS AND PRIVATE_HEADERS)
            pm_warn_devs(
                "pm_target: Executables treat all headers as private, "
                "but ${NAME} has both public and private headers. That is "
                "perhaps nonsensical."
            )
        endif()
        if(DEPENDS AND PRIVATE_DEPENDS)
            pm_warn_devs(
                "pm_target: Executables treat all dependencies as private, "
                "but ${NAME} has both public and private dependencies. That is "
                "perhaps nonsensical."
            )
        endif()

        # Add an executable with `""` for source files, because CMake.
        add_executable(${NAME} "")
        target_sources(${NAME} PRIVATE ${SOURCES_ABS})
        target_sources(${NAME} PRIVATE ${HEADERS_ABS})
        target_sources(${NAME} PRIVATE ${PRIVATE_HEADERS_ABS})
        # TODO: Do we need the install interface for executables? We have to be
        # able to, right?
        target_include_directories(${NAME} PRIVATE
            $<BUILD_INTERFACE:${ABS_INCLUDE_DIR}>
            $<INSTALL_INTERFACE:${INSTALL_INCLUDE_DIR}>
        )
        target_link_libraries(${NAME} PRIVATE ${DEPENDS})
        target_link_libraries(${NAME} PRIVATE ${PRIVATE_DEPENDS})

        # Unless we've exploicitly marked this target or all targets for
        # inclusion in the default build, set EXCLUDE_FROM_ALL to TRUE.
        if(NOT (INCLUDE_IN_DEFAULT_BUILD OR PM_ALL_TARGETS_IN_DEFAULT_BUILD))
            pm_set_target_property(${NAME} EXCLUDE_FROM_ALL TRUE)
        endif()

        # Generate all alias names requested for the target
        foreach(ALIAS IN LISTS ALIASES)
            add_executable(${ALIAS} ALIAS ${NAME})
        endforeach()

        # Are we correctly setting CPack up elsewhere? We should test this.
        set(CPACK_NSIS_MENU_LINKS
            "${CPACK_NSIS_MENU_LINKS}" "${BINARY_DEST}\\${NAME}"
        )

    # TODO: The name "ALIAS" may be a bit of a misnomer here. Maybe there's a
    # better way to describe the aggregate-and-rename trick that's being pulled?
    elseif(ALIAS)
        # Validation specifically for ALIAS targets
        pm_fail(
            IF HEADERS
            WITH "pm_target: Aliased targets can't make sense of "
                 "header files."
        )
        pm_fail(
            IF PRIVATE_HEADERS
            WITH "pm_target: Aliased targets can't make sense of "
                 "private headers."
        )
        pm_fail(
            IF SOURCES
            WITH "pm_target: Aliased targets can't make sense of "
                 "source files."
        )
        pm_fail(
            IF PRIVATE_DEPENDS
            WITH "pm_target: Aliased targets can't make sense of "
                 "privately dependencies."
        )

        string(REGEX REPLACE "[:]" "_" PROXY_NAME ${NAME})
        set(PROXY_NAME ${PROXY_NAME}_proxy)

        add_library(${PROXY_NAME} INTERFACE)
        target_link_libraries(${PROXY_NAME} INTERFACE ${DEPENDS})

        add_library(${NAME} ALIAS ${PROXY_NAME})

    else()
        pm_fail(
            WITH "How did you get here. There should be no way to execute this "
                 "branch. Tell me how you got here."
        )
    endif()

    # Define an Installation Target
    # -----------------------------

    # TODO: Consider adding a SHOULD_INSTALL option to this function? Something
    # more intuitive than some if-soup?
    if(EXECUTABLE OR STATIC_LIBRARY OR DYNAMIC_LIBRARY OR HEADER_ONLY_LIBRARY)
        if(NOT INCLUDE_IN_DEFAULT_BUILD)
            set(OPTIONAL OPTIONAL)
        endif()

        # TODO: Find out if we're ever going to need to separate the LIBRARY
        # and ARCHIVE destinations.
        install(TARGETS ${NAME} EXPORT ${EXPORT_NAME}
            COMPONENT ${COMPONENT}
            ${OPTIONAL}
            RUNTIME DESTINATION ${BINARY_DEST}
            LIBRARY DESTINATION ${LIBRARY_DEST}
            ARCHIVE DESTINATION ${LIBRARY_DEST}
        )
    endif()


    # If the target is a library, install public headers.
    if(STATIC_LIBRARY OR DYNAMIC_LIBRARY OR HEADER_ONLY_LIBRARY)
        pm_install_files(
            ROOT      ${ROOT}
            PATH      ${PATH}
            PREFIX    ${INSTALL_PATH_PREFIX}
            COMPONENT ${COMPONENT}
            FILES     ${HEADERS}
            ${INCLUDE_IN_DEFAULT_BUILD}
        )
    endif()


    # PM_PROPERTIES Proplist Generation
    # ---------------------------------

    # If requested, generate and hand the PM_PROPERTIES proplist back up.
    if(PM_PROPERTIES)
        pm_proplist(INSERT ${PM_PROPERTIES}
            "NAME"        "${NAME}"
            "ALIASES"     "${ALIASES}"
            "COMPONENT"   "${COMPONENT}"
            "ROOT"        "${ROOT}"
            "PATH"        "${PATH}"
            "INCLUDE"     "${INCLUDE}"
        )

        set(TARGET_TYPE "EXECUTABLE")
        if(STATIC_LIBRARY)
            set(TARGET_TYPE "STATIC_LIBRARY")
        elseif(DYNAMIC_LIBRARY)
            set(TARGET_TYPE "DYNAMIC_LIBRARY")
        elseif(HEADER_ONLY_LIBRARY)
            set(TARGET_TYPE "HEADER_ONLY_LIBRARY")
        elseif(ALIAS)
            set(TARGET_TYPE "ALIAS")
        endif()
        pm_proplist(INSERT ${PM_PROPERTIES}
            "TARGET_TYPE" "${TARGET_TYPE}"
        )

        if(LINK_MODE)
            pm_proplist(INSERT ${PM_PROPERTIES}
                "LINK_MODE" "${LINK_MODE}"
            )
        endif()

        set(${PM_PROPERTIES} ${${PM_PROPERTIES}} PARENT_SCOPE)
    endif()
endfunction()
