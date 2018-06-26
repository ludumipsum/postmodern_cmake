include_guard(GLOBAL)

include(pm__core)


# TODO: Proper usage docs, when we're sure the interface won't change.
function(pm_parse_arguments)
    # We will _always_ need an `argn`, even if it's an empty string.
    string(FIND "${ARGN}" "argn" ARGN_INDEX)
    if(ARGN_INDEX EQUAL -1)
        pm_exit(
            "pm_parse_arguments:\n"
            "An 'argn' argument list was not passed for pm_parse_argument to "
            "parse. Did you forget to end the call with `argn \$\{ARGN\}`?")
    endif()

    # Initial Argument Parsing
    # ------------------------
    # NOTE: This function breaks with the convention of ALL_CAPS'ing all the
    # things as an attempt to mark itself as special and avoid collisions with
    # other argument lists. For example, if you're trying to write a function
    # that installs files to a specific path prefix, you'll want to define an
    # argument named `PREFIX`. If we didn't snake_case the keywords used by this
    # function, the desired `PREFIX` argument name would be parsed as the
    # variable-name `prefix` used below.
    set(OPTIONS
        allow_unparsed_arguments
        disallow_unparsed_arguments
        allow_unset_parameters
        disallow_unset_parameters
    )
    set(ARGUMENTS
        prefix
    )
    set(LIST_ARGUMENTS
        options
        arguments
        list_arguments
        positional_arguments
        argn
    )
    cmake_parse_arguments(
        "PARSE_ARGS"
        "${OPTIONS}"
        "${ARGUMENTS}"
        "${LIST_ARGUMENTS}"
        ${ARGN}
    )

    # Initial Argument Validation & Configuration Initialization
    # ----------------------------------------------------------

    # Disallow leaving anything in `${ARGN}` that couldn't be parsed.
    if(PARSE_ARGS_UNPARSED_ARGUMENTS)
        __pm_list__join(PARSE_ARGS_UNPARSED_ARGUMENTS " " STR)
        pm_exit(
            "pm_parse_arguments:\n"
            "pm_parse_arguments was configured with arguments that it does "
            "not know how to parse. Unknown arguments are:\n"
            "${STR}"
        )
    endif()

    # Configure whether or not the second parsing pass should error if it ends
    # with any unparsed arguments.
    if(PARSE_ARGS_allow_unparsed_arguments AND PARSE_ARGS_disallow_unparsed_arguments)
        # `allow_unparsed_arguments` and `disallow_unparsed_arguments` are
        # mutually exclusive arguments.
        pm_exit(
            "pm_parse_arguments:\n"
            "Both `allow_unparsed_arguments` and `disallow_unparsed_arguments` "
            "were set, but these are mutually exclusive arguments. Please "
            "remove one or both. (This function defaults to "
            "disallowing unparsed arguments.)"
        )
    elseif(PARSE_ARGS_allow_unparsed_arguments)
        set(ERROR_ON_UNPARSED_ARGUMENTS FALSE)
    elseif(PARSE_ARGS_disallow_unparsed_arguments)
        set(ERROR_ON_UNPARSED_ARGUMENTS TRUE)
    else() # Default
        set(ERROR_ON_UNPARSED_ARGUMENTS TRUE)
    endif()

    # Configure whether or not the second parsing pass should error if it ends
    # with any unset parameters.
    if(PARSE_ARGS_allow_unset_parameters AND PARSE_ARGS_disallow_unset_parameters)
        # `allow_unset_parameters` and `disallow_unset_parameters` are
        # mutually exclusive arguments.
        pm_exit(
            "pm_parse_arguments:\n"
            "Both `allow_unset_parameters` and `disallow_unset_parameters` "
            "were set, but these are mutually exclusive arguments. Please "
            "remove one or both. (This function defaults to "
            "allowing unset parameters.)"
        )
    elseif(PARSE_ARGS_allow_unset_parameters)
        set(ERROR_ON_UNSET_PARAMETERS FALSE)
    elseif(PARSE_ARGS_disallow_unset_parameters)
        set(ERROR_ON_UNSET_PARAMETERS TRUE)
    else() # Default
        set(ERROR_ON_UNSET_PARAMETERS FALSE)
    endif()

    # If `prefix` was provided we will need to prefix outvars with the string
    # `"${prefix}_"` (note the trailing `_`), so set up an (optionally empty)
    # variable to store the full string.
    if(PARSE_ARGS_prefix)
        set(FULL_PREFIX "${PARSE_ARGS_prefix}_")
    else()
        set(FULL_PREFIX "")
    endif()


    # Primary Argument Parsing
    # ------------------------
    cmake_parse_arguments(
        "_"
        "${PARSE_ARGS_options}"
        "${PARSE_ARGS_arguments}"
        "${PARSE_ARGS_list_arguments}"
        ${PARSE_ARGS_argn}
    )

    # Primary Argument Validation
    # ---------------------------

    # Validate and extract positional arguments from `__UNPARSED_ARGUMENTS`.
    list(LENGTH PARSE_ARGS_positional_arguments POS_ARGS_LEN)
    list(LENGTH __UNPARSED_ARGUMENTS UNPARSED_ARGS_LEN)
    if(POS_ARGS_LEN GREATER UNPARSED_ARGS_LEN)
        __pm_list__join(PARSE_ARGS_positional_arguments ", " POS_ARGS_STR)
        __pm_list__join(__UNPARSED_ARGUMENTS ", " UNPARSED_ARGS_STR)
        pm_exit(
            "pm_parse_arguments:\n"
            "Positional arguments were defined that cannot be set with the "
            "given values.\n"
            "Defined Parameters: ${POS_ARGS_STR}\n"
            "Passed Arguments:   ${UNPARSED_ARGS_STR}"
        )
    endif()

    foreach(POS_ARG IN LISTS PARSE_ARGS_positional_arguments)
        # Single underscores denote an argument to not capture.
        if(POS_ARG STREQUAL "_")
            list(REMOVE_AT __UNPARSED_ARGUMENTS 0)
            continue()
        endif()
        list(GET __UNPARSED_ARGUMENTS 0 POS_ARG_VAL)
        list(REMOVE_AT __UNPARSED_ARGUMENTS 0)
        set(${POS_ARG} ${POS_ARG_VAL} PARENT_SCOPE)
    endforeach()


    # Validate and extract unparsed arguments.
    if(ERROR_ON_UNPARSED_ARGUMENTS AND __UNPARSED_ARGUMENTS)
        __pm_list__join(__UNPARSED_ARGUMENTS ", " STR)
        pm_exit(
            "pm_parse_arguments:\n"
            "Arguments were passed to pm_parse_arguments that were not "
            "parsed when disallow_unparsed_arguments was set to TRUE. "
            "Unparsed arguments are:\n"
            "${STR}"
        )
    else()
        list(LENGTH __UNPARSED_ARGUMENTS COUNT)
        set(UNPARSED_ARGUMENTS ${__UNPARSED_ARGUMENTS} PARENT_SCOPE)
        set(UNPARSED_ARGUMENTS_COUNT ${COUNT} PARENT_SCOPE)
    endif()


    # Validate and extract options, arguments, and list arguments.

    # Zero out a list that will be used to track parameters that were not
    # assigned a value.
    set(UNSET_PARAMETERS_LIST)

    # For options, we check the truthyness of the given parameter.
    # `cmake_parse_arguments` will define all options to either TRUE (if set)
    # or FALSE (if unset). `pm_parse_arguments` explicitly unsets options that
    # are not passed in (rather than setting them to FALSE) and sets the value
    # of options that are passed in to be the option's name. This facilitates
    # pass-through options, as `${MY_OPTION}` will either expand to `MY_OPTION`
    # (if set) or nothing at all (if unset).
    # NB. This does remove the safety from at least one foot-gun. If the name
    # of a set option is a falsy constant (`FALSE`, `OFF`, `.*-NOTFOUND`),
    # `if(THAT-OPTION)` will not evaluate to true. `if(DEFINED THAT-OPTION)`
    # will, but the name of that option will still be a falsy constant.
    # Please don't name your options for falsy constants. It's a bad idea.
    foreach(OPT ${PARSE_ARGS_options})
        if(__${OPT})
            set(${FULL_PREFIX}${OPT} ${FULL_PREFIX}${OPT} PARENT_SCOPE)
        else()
            list(APPEND UNSET_PARAMETERS_LIST "${OPT}")
            unset(${FULL_PREFIX}${OPT} PARENT_SCOPE)
        endif()
    endforeach()

    # For arguments and list arguments, we check if the given parameter is
    # defined, not if it is truthy. Arguments can expand to anything at all,
    # and we want to be sure to allow falsy values to be passed into functions
    # that use `pm_parse_arguments`.
    # If the given argument or list argument is undefined, we explicitly `unset`
    # the parameter in the parent scope to prevent a similarly named variable
    # from a parent's parent scope remaining visible after the
    # `pm_parse_arguments` call.
    foreach(ARG ${PARSE_ARGS_arguments})
        if(DEFINED __${ARG})
            set(${FULL_PREFIX}${ARG} ${__${ARG}} PARENT_SCOPE)
        else()
            list(APPEND UNSET_PARAMETERS_LIST "${ARG}")
            unset(${FULL_PREFIX}${ARG} PARENT_SCOPE)
        endif()
    endforeach()

    foreach(LIST_ARG ${PARSE_ARGS_list_arguments})
        if(DEFINED __${LIST_ARG})
            set(${FULL_PREFIX}${LIST_ARG} ${__${LIST_ARG}} PARENT_SCOPE)
        else()
            list(APPEND UNSET_PARAMETERS_LIST "${LIST_ARG}")
            unset(${FULL_PREFIX}${LIST_ARG} PARENT_SCOPE)
        endif()
    endforeach()

    if(ERROR_ON_UNSET_PARAMETERS AND UNSET_PARAMETERS_LIST)
        __pm_list__join(UNSET_PARAMETERS_LIST ", " STR)
        pm_exit(
            "pm_parse_arguments:\n"
            "Parameters were defined for pm_parse_arguments that were not "
            "assigned vlaues when disallow_unset_parameters was set to "
            "TRUE. Unset parameters are:\n"
            "${STR}"
        )
    else()
        list(LENGTH UNSET_PARAMETERS_LIST COUNT)
        set(UNSET_PARAMETERS ${UNSET_PARAMETERS_LIST} PARENT_SCOPE)
        set(UNSET_PARAMETERS_LIST_COUNT ${COUNT} PARENT_SCOPE)
    endif()
endfunction()
