# NB. We don't include_guard this file set; every time it's included, all tests
# should be allowed to run.

include(pm__core)
include(pm_paths)  # system under test
include(pm_fail)   # required to fail the tests out

function(pm_run_paths_tests)
    pm_status("Running Postmodern Paths Test suite")

    # --- pm_path_to_list

    set(windows_cmake_path "C:/a/windows/cmake/path")
    set(expected_windows_cmake_list "C:/" "a" "windows" "cmake" "path")
    pm_path_to_list(windows_cmake_list ${windows_cmake_path})
    pm_fail(UNLESS windows_cmake_list STREQUAL expected_windows_cmake_list
             SAYING "path_to_list failed for windows-style paths:\n"
                    "  INPUT:    \"${windows_cmake_path}\"\n"
                    "  EXPECTED: \"${expected_windows_cmake_list}\"\n"
                    "  GOT:      \"${windows_cmake_list}\"")

    set(windows_native_path "C:\\a\\windows\\native\\path")
    set(expected_windows_native_list "C:/" "a" "windows" "native" "path")
    pm_path_to_list(windows_native_list ${windows_native_path})
    pm_fail(UNLESS windows_native_list STREQUAL expected_windows_native_list
             SAYING "path_to_list failed for windows-style paths:\n"
                    "  INPUT:    \"${windows_native_path}\"\n"
                    "  EXPECTED: \"${expected_windows_native_list}\"\n"
                    "  GOT:      \"${windows_native_list}\"")

    set(unix_path "/a/unix/path")
    set(expected_unix_list "/" "a" "unix" "path")
    pm_path_to_list(unix_list ${unix_path})
    pm_fail(UNLESS unix_list STREQUAL expected_unix_list
             SAYING "path_to_list failed for unix-style paths:\n"
                    "  INPUT:    \"${unix_path}\"\n"
                    "  EXPECTED: \"${expected_unix_list}\"\n"
                    "  GOT:      \"${unix_list}\"")

    set(relative_path "a/relative/path")
    set(expected_relative_list "a" "relative" "path")
    pm_path_to_list(relative_list ${relative_path})
    pm_fail(UNLESS relative_list STREQUAL expected_relative_list
             SAYING "path_to_list failed for relative-style paths:\n"
                    "  INPUT:    \"${relative_path}\"\n"
                    "  EXPECTED: \"${expected_relative_list}\"\n"
                    "  GOT:      \"${relative_list}\"")

    set(upward_relative_path "an/../upward/../path/../../..")
    set(expected_upward_relative_list ".." "..")
    pm_path_to_list(upward_relative_list ${upward_relative_path})
    pm_fail(UNLESS upward_relative_list STREQUAL expected_upward_relative_list
             SAYING "path_to_list failed for upward_relative-style paths:\n"
                    "  INPUT:    \"${upward_relative_path}\"\n"
                    "  EXPECTED: \"${expected_upward_relative_list}\"\n"
                    "  GOT:      \"${upward_relative_list}\"")

    pm_status("Running Postmodern Paths Test suite -- done")
endfunction()
