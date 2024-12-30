---
title: Makefile简介
description: 介绍makefile的基本语法以及项目实践。
date: 2018-07-27T12:38:51+08:00
tags: [
    "golang",
    "makefile",
    "tutorial"
]
categories: [
    "开发",
]
cover:
  image: gnu-make.png
draft: false
---


网络上关于 `makefile`的教程有很多，由于我日常不是写`c/c++`的，
不常使用`makefile`，需要用的时候总是要重新Google搜索makefile的语法。

索性整理出来这篇 makefile 教程，备忘。

## 教程
Makefile简易教程：
### 基本语法
```makefile
target: dependency1 dependency2 ...
[TAB] action1
[TAB] action2
   ...

```
下面的makefile摘抄自[GNU Make in Detail for Beginners](https://opensourceforu.com/2012/06/gnu-make-in-detail-for-beginners/)，这篇入门文章把makefile的语法写的非常透彻。

推荐大家多读几遍
```makefile
##### makefile for compile C programs
# Compiler to use
CC = gcc
# -g for debug, -O2 for optimise and -Wall additonal messages
OPTIONS = -O2 -g -Wall
# Directory for header file
INCLUDES = -I . 
# List of objects to be build
OBJS = main.o module.o
.PHONY: all list clean

all: ${OBJS}
    @echo "Building..." # print "Building..." message
    ${CC} ${OPTIONS} ${INCLUDES} ${OBJS} -o main_bin

%.o: %.c  # '%' pattern wildcard matching
    ${CC} ${OPTIONS} ${INCLUDES} -c %.c

list:
    @echo $(shell ls) # print output of command `ls`

clean:
    @echo Cleaning up...
    -rm -rf *.0 # '-' prefix for ignoring errors and continue execution
    -rm main_bin


#### makefile for img manage
FILES = $(shell find imgs -type f -iname "*.jpg" | sed 's/imgs/thumb/g')
CONVERT_CMD = convert -resize "100x100" $< $@
MSG = "\nUpdating thumbnail" $@

all_thumb: ${FILES}

thumb/%.jpg: imgs/%.jpg
    ${MSG}
    ${CONVERT_CMD}

thumb/%.JPG: imgs/%.JPG
    ${MSG}
    ${CONVERT_CMD}

clean_all:
    @echo Cleaning up files...
    -rm -rf thumb/*.{jpg,JPG}
```

### 变量
#### 赋值
##### Simple assignment (:=)
We can assign values (RHS) to variables (LHS) with this operator, for example: CC := gcc. With simple assignment (:=), the value is expanded and stored to all occurrences in the Makefile when its first definition is found.

For example, when a CC := ${GCC} ${FLAGS} simple definition is first encountered, CC is set to gcc -W and wherever ${CC} occurs in actions, it is replaced with gcc -W.

##### Recursive assignment (=)
Recursive assignment (the operator used is =) involves variables and values that are not evaluated immediately on encountering their definition, but are re-evaluated every time they are encountered in an action that is being executed. As an example, say we have:

GCC = gcc
FLAGS = -W
With the above lines, CC = ${GCC} {FLAGS} will be converted to gcc -W only when an action like ${CC} file.c is executed somewhere in the Makefile. With recursive assignation, if the GCC variable is changed later (for example, GCC = c++), then when it is next encountered in an action line that is being updated, it will be re-evaluated, and the new value will be used; ${CC} will now expand to c++ -W.

We will also have an interesting and useful application further in the article, where this feature is used to deal with varying cases of filename extensions of image files.

##### Conditional assignment (?=)
Conditional assignment statements assign the given value to the variable only if the variable does not yet have a value.

##### Appending (+=)
The appending operation appends texts to an existing variable. For example:

CC = gcc
CC += -W
CC now holds the value gcc -W.


#### action内置变量
The `%` character can be used for wildcard pattern-matching, to provide generic targets. For example:
```makefile
%.o: %.c
[TAB] actions
```
When `%` appears in the dependency list, it is replaced with the same string that was used to perform substitution in the target.
Inside actions, we can use special variables for matching filenames. Some of them are:
```makefile
$@ (full target name of the current target)
$? (returns the dependencies that are newer than the current target)
$* (returns the text that corresponds to % in the target)
$< (name of the first dependency)

dep.o: dep.src config1.cfg config2.cfg
    @echo the second preq is $(word 2,$^), the third is $(word 3,$^)


$^ (name of all the dependencies with space as the delimiter)
Instead of writing each of the file names in the actions and the target, we can use shorthand notations based on the above, to write more generic Makefiles.

```
### action modifiers
We can change the behaviour of the actions we use by prefixing certain action modifiers to the actions. Two important action modifiers are:

#### - (minus) 
Prefixing `-` to any action causes any error that occurs while executing the action to be ignored.

By default, execution of a Makefile stops when any command returns a non-zero (error) value. 
If an error occurs, a message is printed, with the status code of the command, and noting that the error has been ignored. 
Looking at the Makefile from our sample project: in the clean target, the rm target_bin command will produce an error if that file does not exist (this could happen if the project had never been compiled, or if make clean is run twice consecutively). 
To handle this, we can prefix the rm command with a minus, to ignore errors: -rm target_bin.

#### @ (at) 
`@` suppresses the standard print-action-to-standard-output behaviour of make, for the action/command that is prefixed with @. 
For example, to echo a custom message to standard output, we want only the output of the echo command, and don’t want to print the echo command line itself. @echo Message will print “Message” without the echo command line being printed.

#### .PHONY
Use PHONY to avoid file-target name conflicts.
Remember the all and clean special targets in our Makefile? 
What happens when the project directory has files with the names all or clean? 
The conflicts will cause errors.
Use the `.PHONY` directive to specify which targets are not to be treated as files — for example: `.PHONY: all clean`.


### 其它
#### dry run
Simulating make without actual execution.
At times, maybe when developing the Makefile, we may want to trace the make execution (and view the logged messages) without actually running the actions, which is time consuming. 
Simply use `make -n` to do a “dry run”.

#### shell
Using the shell command output in a variable
Sometimes we need to use the output from one command/action in other places in the Makefile — for example, checking versions/locations of installed libraries, or other files required for compilation. 
We can obtain the shell output using the shell command. 
For example, to return a list of files in the current directory into a variable, we would run: `LS_OUT = $(shell ls)`.

#### Nested Makefiles
Nested Makefiles (which are Makefiles in one or more subdirectories that are also executed by running the make command in the parent directory) can be useful for building smaller projects as part of a larger project. To do this, we set up a target whose action changes directory to the subdirectory, and invokes make again:

```makefile
subtargets:
    cd subdirectory && $(MAKE)
```
Instead of running the make command, we used `$(MAKE)`, an environment variable, to provide flexibility to include arguments. 
For example, if you were doing a “dry run” invocation: if we used the make command directly for the subdirectory, the simulation option (-n) would not be passed, and the commands in the subdirectory’s Makefile would actually be executed. 
To enable use of the -n argument, use the $(MAKE) variable.


## 实践
在golang项目里的[实践](https://github.com/datewu/project-abc/blob/master/Makefile)：
```makefile
# Include variables from .envrc files
-include .envrc

# ==================================================================================== #
# HELPERS
# ==================================================================================== #

## help: print this help message
.PHONY: help
help:
	@echo "\t##IMPORTANT##: please run 'echo .envrc >> .gitignore' at very first time"
	@echo 'Usage:'
	@sed -n 's/^##//p' ${MAKEFILE_LIST} | column -t -s ':' |  sed -e 's/^/ /'

# Create the new confirm target.
.PHONY: confirm
confirm:
	@echo -n 'Are you sure? [y/N] ' && read ans && [ $${ans:-N} = y ]

# ==================================================================================== #
# DEVELOPMENT
# ==================================================================================== #

## run/main: run the cmd/main binary file
.PHONY: run/main
run/main:
	go run ./cmd

## run/debug: debug app use dlv
.PHONY: run/debug
run/debug:
	dlv debug ./cmd --headless --listen :4040

## run/test: runs go test with default values
.PHONY: run/test
run/test:
	go test -timeout 300s -v -count=1 -race ./...

## run/update: runs go get -u && go mod tidy
.PHONY: run/update
run/update:
	go get -u ./...
	go mod tidy

## db/psql: connection to the database using psql
.PHONY: db/psql
db/psql:
	@psql ${PG_DSN}

## db/generate use sqlc generated models and queries
.PHONY: db/generate
db/generate:
	@echo 'sqlc generate in internal/sqlc fold'
	@cd internal/sqlc && sqlc generate && cd ../..

## db/migrations/new name=$1: create a new database migration
.PHONY: db/migrations/new
db/migrations/new:
	@echo 'Creating migrate files for ${name}'
	@migrate create -seq -ext=.sql -dir=./migrations ${name}

## db/migrations/up: apply all up database migrations
.PHONY: db/migrations/up
db/migrations/up: confirm
	@echo 'Running up migrations...'
	@migrate -path ./migrations -database ${PG_DSN} up

# ==================================================================================== #
# QUALITY CONTROL
# ==================================================================================== #

## audit: tidy dependencies and format, vet and test all code
.PHONY: audit
audit:
	@echo 'Tidying and verifying module dependencies...'
	go mod tidy
	go mod verify
	@echo 'Formatting code...'
	go fmt ./...
	@echo 'Vetting code...'
	go vet ./...
	#staticcheck ./...  # go install honnef.co/go/tools/cmd/staticcheck@latest
	@echo 'Running tests...'
	go test -race -vet=off ./...

## vendor: tidy and vendor dependencies
.PHONY: vendor
vendor:
	@echo 'Tidying and verifying module dependencies...'
	go mod tidy
	go mod verify
	@echo 'Vendoring dependencies...'
	go mod vendor

# ==================================================================================== #
# BUILD
# ==================================================================================== #

#current_time = $(shell date --iso-8601=seconds)
current_time = $(shell date -u +"%Y-%m-%dT%H:%M:%SZ")
git_description = $(shell git describe --always --dirty --tags --long)
linker_flags = '-s -X main.buildTime=${current_time} -X main.version=${git_description}'

## build/api: build the cmd/api application
.PHONY: build/api
build/main: audit
	@echo 'Building cmd/...'
	go build -ldflags=${linker_flags} -o=./bin/cmd ./cmd
	#go tool dist list
	GOOS=linux GOARCH=amd64 go build -ldflags=${linker_flags} -o=./bin/linux_amd64/cmd ./cmd

## build/dlv-debug: build the application with dlv gcflags
.PHONY: build/dlv-debug
build/dlv-debug: 
	@echo "Building for delve debug..."
	@go build \
	-ldflags ${linker_flags} \
	-ldflags=-compressdwarf=false \
	-gcflags=all=-d=checkptr \
	-gcflags="all=-N -l" \
	-o ./bin/debug ./cmd
```
