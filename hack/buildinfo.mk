#  max build number 2147483647
#                    220217115
# time build number  22011218n
#                     y m d H n=M/6
# each 6 minute could only one build
GIT_COMMIT_TIME = $(shell git log --no-decorate -n1 --date='format:%y%m%d%H' --format='format:%cd' )
GIT_COMMIT_TIME_MINUTE = $(shell git log --no-decorate -n1 --date='format:%M' --format='format:%cd' )
BUILD_NUMBER = $(GIT_COMMIT_TIME)$(shell echo `expr $(GIT_COMMIT_TIME_MINUTE) / 6`)

export
