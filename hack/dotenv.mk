include .env

ifneq ( ,$(wildcard .env.local))
	include .env.local
endif

export
