# Pier CLI Toolset
Pier is a command line toolset for installing and running Docker-based dev environments for my various projects.

## Vision
The `pier` and `moor` command line tools were created in order to allow for commands to be ran on projects hosted in a VM, especially a [Pier 11](https://github.com/lightster/pier-11) VM, without me needing to SSH into the VM.

## Requirements
Before installing Pier, you will need to install a recent version of Ruby.  Pier is tested with Ruby 2.4.1 but may work with other versions.

RVM is the recommended way of installing Ruby:
```bash
gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB

\curl -sSL https://get.rvm.io | bash -s stable

rvm install ruby-2.4.1
```

## Installation

```bash
git clone git@github.com:lightster/pier-cli.git

cd pier-cli

./configure
make install
```

Additionally, if you want to be able to use `moor cd` to change directories between projects, make sure to add the following to your `~/.bashrc`:

```bash
source /path/to/pier-cli/bin/bash_functions.sh
```

## Moor usage
```bash
[~] $ cd path/to/workspace

[workspace] $ moor help
Usage:
  moor COMMAND

Available commands:
  cd                Change directories to the root of a project
  config            Set config option that all projects in workspace will have access to
  docker-compose    Run a docker-compose command on the project found in the current working directory
  install           Install a project
  help              Output this help documentation

# install lightster/hodor project from github.com
[workspace] $ moor install lightster/hodor

# install other projects from github.com
[workspace] $ moor install lightster/yo-pdo
[workspace] $ moor install hold-the-door/ravens

# change to a project's directory
[workspace] $ moor cd lightster/hodor
[hodor] $

# you don't need to think relative to the current working directory
# `moor cd` knows where your projects are stored
[hodor] $ moor cd lightster/yo-pdo
[yo-pdo] $

# get back to the workspace root
[yo-pdo] $ moor cd
[workspace] $ moor cd hold-the-door/ravens

# run a docker-compose command for project hosted in CWD
[ravens] $ moor docker-compose run --rm php test
Starting ravens_rabbitmq_1 ... done
PHPUnit 4.8.23 by Sebastian Bergmann and contributors.

...............................................................  63 / 104 ( 60%)
.........................................

Time: 7.66 seconds, Memory: 15.50Mb

OK (104 tests, 131 assertions)

Generating code coverage report in Clover XML format ... done

Generating code coverage report in HTML format ... done
```
