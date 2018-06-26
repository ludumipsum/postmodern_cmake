# NB. We don't include_guard this file set; every time it's included, all tests
# should be allowed to run.

include(pm_fail.test)
pm_run_fail_tests()

include(pm_list.test)
pm_run_list_tests()

include(pm_boolean.test)
pm_run_boolean_tests()

include(pm_math.test)
pm_run_math_tests()

include(pm_paths.test)
pm_run_paths_tests()

include(pm_proplist.test)
pm_run_proplist_tests()
