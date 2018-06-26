include_guard(GLOBAL)

include(CMakePackageConfigHelpers)
include(pm__core)
include(pm_fail)
include(pm_parse_arguments)
include(pm_paths)


# TODOs:
#   - Usage docs.
#   - Figure out if there's some way to verify that `${COMPONENT}-targets` is a
#     defined export target.
function(pm_export_component COMPONENT)
    pm_parse_arguments(
        arguments
            NAMESPACE
            CONFIG_FILE_TEMPLATE
            INSTALL_PREFIX
        argn ${ARGN}
    )

    pm_fail(
        IF_NOT_SET COMPONENT
        WITH "pm_export_component must be give a component to export!"
    )

    pm_set_if_unset(NAMESPACE "${COMPONENT}::")

    pm_set_if_unset(CONFIG_FILE_TEMPLATE "${COMPONENT}-config.cmake.in")
    get_filename_component(CONFIG_FILE_TEMPLATE "${CONFIG_FILE_TEMPLATE}" ABSOLUTE)

    pm_set_if_unset(INSTALL_PREFIX "lib/cmake")
    pm_resolve_path(INSTALL_PREFIX "${INSTALL_PREFIX}")

    pm_fail(
        WHEN NOT EXISTS "${CONFIG_FILE_TEMPLATE}"
        WITH "Export Component could not find the '${CONFIG_FILE_TEMPLATE}' "
             "configuration file."
    )

    configure_package_config_file(
        ${CONFIG_FILE_TEMPLATE}
        ${PROJECT_BINARY_DIR}/${COMPONENT}-config.cmake
        INSTALL_DESTINATION ${INSTALL_PREFIX}/${COMPONENT}
    )
    install(EXPORT ${COMPONENT}-targets
        NAMESPACE ${NAMESPACE}
        DESTINATION ${INSTALL_PREFIX}/${COMPONENT}
    )
    install(FILES
        ${PROJECT_BINARY_DIR}/${COMPONENT}-config.cmake
        DESTINATION ${INSTALL_PREFIX}/${COMPONENT}
    )
endfunction()
