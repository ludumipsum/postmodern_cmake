# NB. We don't include_guard this file set; every time it's included, all tests
# should be allowed to run.

include(pm__core)
include(pm_fail)  # system under test

# Because pm_fail is designed to stop the CMake configuration step, this is
# going to be more of an API demo than a proper test.
# Add an extra `#` to the front of any of these block comments (`#[[ ... ]]`) to
# see the gated call stop the program's execution, be it because a condition was
# met, or because the call was malformed.
function(pm_run_fail_tests)
    message(STATUS "Running Postmodern Fail Test suite")

    # `pm_fail` is designed to halt the execution of the CMake configuration
    # step in a conditional, functional, and easy-to-understand way. At most,
    # the command will take one "Conditional Command" (e.g. `IF`) followed by a
    # conditional expression, and one "Message Command" (e.g. "MESSAGE") and a
    # list of strings to print when the given condition is met. Either or both
    # may be omitted, though. For example;
    #
    #  pm_fail(
    #      IF TRUE
    #      WITH
    #          "This will always stop CMake execution. The `IF TRUE`"
    #          "conditional clause will always trigger a FATAL_ERROR.\n"
    #          "Newlines can be added to the given message to print a paragraph"
    #          "break. CMake's formatter will largely be left to its own"
    #          "devices, though, for better or worse."
    #  )


    # None of these should trigger; their conditionals are un-met.
    pm_fail(IF       FALSE MESSAGE "<-- 1st way to print a message.")
    pm_fail(WHEN     FALSE WITH    "<-- 2nd way to print a message.")
    pm_fail(IF_NOT   TRUE  SAYING  "<-- 3rd way to print a message.")
    pm_fail(UNLESS   TRUE)
    pm_fail(WHEN_NOT TRUE)


    # All of these should trigger; their conditionals are met.
    # ------------------------------------
    #[[
    pm_fail() #]]
    #[[
    pm_fail(IF TRUE) #]]
    #[[
    pm_fail(WHEN TRUE) #]]
    #[[
    pm_fail(IF_NOT FALSE) #]]
    #[[
    pm_fail(UNLESS FALSE) #]]
    #[[
    pm_fail(WHEN_NOT FALSE) #]]

    # If no condition is given, the fail will always trigger
    # ------------------------------------
    #[[
    pm_fail() #]]
    #[[
    pm_fail(MESSAGE "An unconditional failure.") #]]
    #[[
    pm_fail(WITH    "A failure message.") #]]
    #[[
    pm_fail(SAYING  "Something about the failure.") #]]

    # In addition to simple boolean logic, `pm_fail` can check to see if
    # variables are defined, regardless of value.
    # ------------------------------------
    #[[
    set(V "")
    pm_fail(IF_SET V      SAYING "But it's set to the empty string.") #]]
    #[[
    unset(V)
    pm_fail(IF_NOT_SET V  SAYING "V was `unset`.") #]]
    #[[
    set(V "")
    set(V) # This is the same as `unset(V)`. For reasons?
    pm_fail(IF_NOT_SET V  SAYING "V was reset, but then `unset`. Again.") #]]

    # Complex expressions are likely going to be the more common conditional
    # ------------------------------------
    #[[
    pm_fail(IF "a" STREQUAL "a") #]]
    #[[
    pm_fail(IF NOT FALSE AND "a" STREQUAL "a") #]]
    #[[
    pm_fail(IF_NOT FALSE OR "a" STREQUAL "A") #]]

    # The different Conditional Commands are mutually exclusive, and `pm_fail`
    # will print a helpful message if more than one are given.
    # ------------------------------------
    #[[
    pm_fail(IF TRUE WHEN FALSE) #]]
    #[[
    # These two conditionals agree. I don't care. Don't do this.
    pm_fail(IF_NOT TRUE UNLESS TRUE) #]]

    # The same is true for Message Commands
    # ------------------------------------
    #[[
    pm_fail(MESSAGE "A message..." SAYING "... and a quote.") #]]

    message(STATUS "Running Postmodern Fail Test suite -- done")
endfunction()
