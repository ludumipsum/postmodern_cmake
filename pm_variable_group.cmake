include_guard(GLOBAL)

include(pm__core)
include(pm_parse_arguments)


function(pm_variable_group)
    pm_parse_arguments(
        arguments
            NAME
        list_arguments
            VARIABLES
        options
            CAPTURE_FULL_LIST
            CAPTURE_COUNT
            CAPTURE_SET_LIST
            CAPTURE_NUMBER_SET
            CAPTURE_UNSET_LIST
            CAPTURE_NUMBER_UNSET
            CAPTURE_TRUTHY_LIST
            CAPTURE_NUMBER_TRUTHY
            CAPTURE_FALSY_LIST
            CAPTURE_NUMBER_FALSY
        argn ${ARGN}
    )

    # If no capture types were set, capture them all.
    if(NOT CAPTURE_FULL_LIST   AND NOT CAPTURE_COUNT AND
       NOT CAPTURE_SET_LIST    AND NOT CAPTURE_NUMBER_SET AND
       NOT CAPTURE_UNSET_LIST  AND NOT CAPTURE_NUMBER_UNSET AND
       NOT CAPTURE_TRUTHY_LIST AND NOT CAPTURE_NUMBER_TRUTHY AND
       NOT CAPTURE_FALSY_LIST  AND NOT CAPTURE_NUMBER_FALSY)
        set(CAPTURE_FULL_LIST TRUE)
        set(CAPTURE_COUNT TRUE)
        set(CAPTURE_SET_LIST TRUE)
        set(CAPTURE_NUMBER_SET TRUE)
        set(CAPTURE_UNSET_LIST TRUE)
        set(CAPTURE_NUMBER_UNSET TRUE)
        set(CAPTURE_TRUTHY_LIST TRUE)
        set(CAPTURE_NUMBER_TRUTHY TRUE)
        set(CAPTURE_FALSY_LIST TRUE)
        set(CAPTURE_NUMBER_FALSY TRUE)
    endif()

    set(GROUP_SET_LIST)
    set(GROUP_UNSET_LIST)
    set(GROUP_TRUTHY_LIST)
    set(GROUP_FALSY_LIST)

    foreach(Vn ${VARIABLES})
        if(DEFINED ${Vn})
            # Vn is set; update the *_SETl outvar.
            list(APPEND GROUP_SET_LIST ${Vn})
            if(${Vn})
                # Vn is set and evaluates to TRUE; update the *_TRUTHY outvars.
                list(APPEND GROUP_TRUTHY_LIST ${Vn})
            else()
                # Vn is set but evaluates to FALSE; update the *_FALSY outvars.
                list(APPEND GROUP_FALSY_LIST ${Vn})
            endif()
        else()
            # Vn is not set; update the *_UNSET and *_FALSY outvars.
            list(APPEND GROUP_UNSET_LIST ${Vn})
            list(APPEND GROUP_FALSY_LIST ${Vn})
        endif()
    endforeach()


    if(CAPTURE_FULL_LIST)
        set(${NAME}_FULL_LIST ${VARIABLES} PARENT_SCOPE)
    endif()
    if(CAPTURE_COUNT)
        list(LENGTH VARIABLES LEN)
        set(${NAME}_COUNT ${LEN} PARENT_SCOPE)
    endif()
    if(CAPTURE_SET_LIST)
        set(${NAME}_SET_LIST ${GROUP_SET_LIST} PARENT_SCOPE)
    endif()
    if(CAPTURE_NUMBER_SET)
        list(LENGTH GROUP_SET_LIST LEN)
        set(${NAME}_NUMBER_SET ${LEN} PARENT_SCOPE)
    endif()
    if(CAPTURE_UNSET_LIST)
        set(${NAME}_UNSET_LIST ${GROUP_UNSET_LIST} PARENT_SCOPE)
    endif()
    if(CAPTURE_NUMBER_UNSET)
        list(LENGTH GROUP_UNSET_LIST LEN)
        set(${NAME}_NUMBER_UNSET ${LEN} PARENT_SCOPE)
    endif()
    if(CAPTURE_TRUTHY_LIST)
        set(${NAME}_TRUTHY_LIST ${GROUP_TRUTHY_LIST} PARENT_SCOPE)
    endif()
    if(CAPTURE_NUMBER_TRUTHY)
        list(LENGTH GROUP_TRUTHY_LIST LEN)
        set(${NAME}_NUMBER_TRUTHY ${LEN} PARENT_SCOPE)
    endif()
    if(CAPTURE_FALSY_LIST)
        set(${NAME}_FALSY_LIST ${GROUP_FALSY_LIST} PARENT_SCOPE)
    endif()
    if(CAPTURE_NUMBER_FALSY)
        list(LENGTH GROUP_FALSY_LIST LEN)
        set(${NAME}_NUMBER_FALSY ${LEN} PARENT_SCOPE)
    endif()
endfunction()
