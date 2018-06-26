include_guard(GLOBAL)

include(pm__core.disallow_special_names)
include(pm__core.msg)


# Being able to join CMake lists into pretty-printable strings is a very
# important feature to have at all levels. `pm_list(JOIN)` is the intended
# user-facing interface, but `pm_list` relies on too many other functions for
# it to be safely used at the lower levels of this library -- a cyclic
# dependency between `pm_list` and `pm_parse_arguments`, for example, could
# easily lead to an infinite loop between the two functions. This file, and the
# pseudo-private `__pm_list__join` function is here for the sole purpose of
# preventing such cyclic dependencies.
# Thanks to https://stackoverflow.com/questions/7172670#7216542 for inspiring
# the implementation.
function(__pm_list__join LISTln GLUE OUTn)
    # Disallow CMake's special vars, but let PM vars through.
    pm_loosely_disallow_special_names(${LISTln})

    string(REGEX REPLACE "([^\\]|^);" "\\1${GLUE}" RET "${${LISTln}}")
    string(REGEX REPLACE "[\\](.)" "\\1" RET "${RET}") # strip escaping

    set(${OUTn} "${RET}" PARENT_SCOPE)
endfunction()
