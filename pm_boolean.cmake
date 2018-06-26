include_guard(GLOBAL)

include(pm__core)

# pm_bool(NOT [<out>] <var>)
# pm_bool(AND [<out>] <var1> <var2>)
# pm_bool(OR [<out>] <var1> <var2>)
# pm_bool(XOR [<out>] <var1> <var2>)
# pm_bool(ANY <out> <var1> [<var2> ...])
# pm_bool(ALL <out> <var1> [<var2> ...])
# pm_bool(ONE <out> <var1> [<var2> ...])
# pm_bool(NONE <out> <var1> [<var2> ...])
function(pm_bool CMD)

    # pm_bool(NOT [<out>] <var>)
    # ----------------------------------------------------------------
    if(CMD STREQUAL NOT)
        if(${ARGC} EQUAL 2)
            set(OUTn ${ARGV1})
            set(VARn ${ARGV1})
        elseif(${ARGC} EQUAL 3)
            set(OUTn ${ARGV1})
            set(VARn ${ARGV2})
        else()
            pm_exit(
                "pm_bool(NOT [<out>] <var>) "
                "Called with the wrong number of arguments"
            )
        endif()

        if(${VARn})
            set(${OUTn} FALSE PARENT_SCOPE)
        else()
            set(${OUTn} TRUE PARENT_SCOPE)
        endif()


    # pm_bool(AND <out> <var1> <var2> [<var3> ...])
    # ----------------------------------------------------------------
    elseif(CMD STREQUAL AND)
        if(NOT ${ARGC} GREATER_EQUAL 3)
            pm_exit(
                "pm_bool(AND <out> <var1> <var2> [<var3> ...]) "
                "Called with the wrong number of arguments"
            )
        endif()

        list(GET       ARGN 0 OUTn)
        list(REMOVE_AT ARGN 0)

        # Default the out var to true
        set(${OUTn} TRUE PARENT_SCOPE)

        # Test all provided Vars. Short-circut if any evaluate to FALSE.
        foreach(V IN LISTS ARGN)
            if(NOT ${V})
                set(${OUTn} FALSE PARENT_SCOPE)
                return()
            endif()
        endforeach()


    # pm_bool(OR <out> <var1> <var2> [<var3> ...])
    # ----------------------------------------------------------------
    elseif(CMD STREQUAL OR)
        if(NOT ${ARGC} GREATER_EQUAL 4)
            pm_exit(
                "pm_bool(OR <out> <var1> <var2> [<var3> ...]) "
                "Called with the wrong number of arguments"
            )
        endif()

        list(GET       ARGN 0 OUTn)
        list(REMOVE_AT ARGN 0)

        # Default the out var to false
        set(${OUTn} FALSE PARENT_SCOPE)

        # Test all provided Vars. Short-circut if any evaluate to TRUE.
        foreach(V IN LISTS ARGN)
            if(${V})
                set(${OUTn} TRUE PARENT_SCOPE)
                return()
            endif()
        endforeach()


    # pm_bool(XOR <out> <var1> <var2> [<var3> ...])
    # ----------------------------------------------------------------
    elseif(CMD STREQUAL XOR)
        if(NOT ${ARGC} GREATER_EQUAL 4)
            pm_exit(
                "pm_bool(XOR <out> <var1> <var2> [<var3> ...]) "
                "Called with the wrong number of arguments"
            )
        endif()

        list(GET       ARGN 0 OUTn)
        list(GET       ARGN 1 VAR1)
        list(REMOVE_AT ARGN 0 1)

        # XOR cannot short circuit, so we prime the out var to VAR1...
        if(${VAR1})
            set(RET TRUE)
        else()
            set(RET FALSE)
        endif()

        # ... then loop through all remaning vars, performing a
        # left-associative XOR fold
        foreach(V IN LISTS ARGN)
            if((NOT (${RET} AND ${V})) AND (${RET} OR ${V}))
                set(RET TRUE)
            else()
                set(RET FALSE)
            endif()
        endforeach()

        set(${OUTn} ${RET} PARENT_SCOPE)


    # pm_bool(ANY <out> <var>...)
    # ----------------------------------------------------------------
    elseif(CMD STREQUAL ANY)
        if(NOT ${ARGC} GREATER_EQUAL 2)
            pm_exit(
                "pm_bool(ANY <out> <var>...) "
                "Called with too few arguments"
            )
        endif()

        list(GET       ARGN 0 OUTn)
        list(REMOVE_AT ARGN 0)

        # NB. We don't need to special-case if we were given an empty list.
        # Prime the out var; if we don't short circuit, this is what we'll get.
        set(${OUTn} FALSE PARENT_SCOPE)

        foreach(V IN LISTS ARGN)
            if(${V})
                set(${OUTn} TRUE PARENT_SCOPE)
                return()
            endif()
        endforeach()


    # pm_bool(ALL <out> <var>...)
    # ----------------------------------------------------------------
    elseif(CMD STREQUAL ALL)
        if(NOT ${ARGC} GREATER_EQUAL 2)
            pm_exit(
                "pm_bool(ALL <out> <var>...) "
                "Called with too few arguments"
            )
        endif()

        list(GET       ARGN 0 OUTn)
        list(REMOVE_AT ARGN 0)

        # If we were given an empty list, special-case to FALSE
        if(${ARGC} EQUAL 2)
            set(${OUTn} FALSE PARENT_SCOPE)
            return()
        endif()

        # Prime the out var; if we don't short circuit, this is what we'll get.
        set(${OUTn} TRUE PARENT_SCOPE)

        foreach(V IN LISTS ARGN)
            if(NOT ${V})
                set(${OUTn} FALSE PARENT_SCOPE)
                return()
            endif()
        endforeach()


    # pm_bool(ONE <out> <var>...)
    # ----------------------------------------------------------------
    elseif(CMD STREQUAL ONE)
        if(NOT ${ARGC} GREATER_EQUAL 2)
            pm_exit(
                "pm_bool(ONE <out> <var>) "
                "Called with too few arguments"
            )
        endif()

        list(GET       ARGN 0 OUTn)
        list(REMOVE_AT ARGN 0)

        # NB. We don't need to special-case if we were given an empty list.
        # Prime the out var
        set(RET FALSE)

        foreach(V IN LISTS ARGN)
            if(${V})
                if(NOT ${RET})
                    # If this is the first truthy val, set RET to TRUE
                    set(RET TRUE)
                else()
                    # Two or more of this set are TRUE; early out
                    set(${OUTn} FALSE PARENT_SCOPE)
                    return()
                endif()
            endif()
        endforeach()

        set(${OUTn} ${RET} PARENT_SCOPE)


    # pm_bool(NONE <out> <var>...)
    # ----------------------------------------------------------------
    elseif(CMD STREQUAL NONE)
        if(NOT ${ARGC} GREATER_EQUAL 2)
            pm_exit(
                "pm_bool(NONE <out> <var>...) "
                "Called with too few arguments"
            )
        endif()

        list(GET       ARGN 0 OUTn)
        list(REMOVE_AT ARGN 0)

        # If we were given an empty list, special-case to TRUE
        if(${ARGC} EQUAL 2)
            set(${OUTn} TRUE PARENT_SCOPE)
            return()
        endif()

        # Prime the out var; if we don't short circuit, this is what we'll get.
        set(${OUTn} TRUE PARENT_SCOPE)

        foreach(V IN LISTS ARGN)
            if(${V})
                set(${OUTn} FALSE PARENT_SCOPE)
                return()
            endif()
        endforeach()


    else()
        pm_exit("pm_boolean: given unknown commad; ${CMD}")

    endif()
endfunction()
