# Pier CLI Toolset
Pier is a command line toolset for installing and running Docker-based dev environments for my various projects.

## Vision
The `pier` and `moor` command line tools were created in order to allow for commands to be ran on projects hosted in a VM, especially a [Pier 11](https://github.com/lightster/pier-11) VM, without needing to manually SSH into the VM.

The Pier toolset also encourages projects to be funneled through one command—the `pier` command.  This will hopefully make it easier for developers to find needed commands without needing to sift through readme files or source code.

### What are Pier and Moor?
The `moor` command is used for managing workspaces and projects.  The `moor` command allows you to:
- Initialize a workspace
- Install projects (repositories) from GitHub
- Change your terminal’s working directory to a project directory
- Run ad-hoc docker-compose commands on a project
- Set config options within the workspace and projects

The `pier` command is used for running commands that are defined by each project.  Example commands that a project may provide would allow you to:
- Run a test suite
- Execute database migrations
- Restart container services
- Interface with the project’s CLI or REPL

## Installation
### Requirements
Before installing Pier, you will need to install a recent version of Ruby.  Pier is tested with Ruby 2.4.1 but may work with other versions.

RVM is the recommended way of installing Ruby:
```bash
gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB

\curl -sSL https://get.rvm.io | bash -s stable

rvm install ruby-2.4.1
```

### Install Pier and Moor CLI Tools
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
### Using the `help` command
If you remember nothing else about `moor`, remember `moor help`. You can reference it anytime you forget which commands are available.
```ShellSession
[lightster@local:~] $ cd path/to/workspace

[lightster@local:workspace] $ moor help
Usage:
  moor COMMAND

Available commands:
  cd                Change directories to the root of a project
  config            Set config option that all projects in workspace will have access to
  docker-compose    Run a docker-compose command on the project found in the current working directory
  install           Install a project
  help              Output this help documentation
```

### Installing projects
Before we can any `pier` commands and most `moor` commands, we need to install some projects.  Projects are any Git repository hosted on GitHub.  To install a project, use `moor install` followed by a project name.
```ShellSession
# install projects project from github.com
[lightster@local:workspace] $ moor install lightster/hodor
[lightster@local:workspace] $ moor install lightster/yo-pdo
[lightster@local:workspace] $ moor install hold-the-door/ravens
```

By default, `moor install` will run `./configure pier` and `make install` if a `configure` script and/or a `Makefile`, respectively, exist in the project’s root directory.

### Changing to a project’s directory
If you install the `bash_functions.sh`, `moor` provides a `cd` command that allows you to change to a project’s directory from anywhere within your workspace.
```ShellSession
[lightster@local:workspace] $ moor cd lightster/hodor
[lightster@local:hodor] $ moor cd lightster/yo-pdo

# get back to the workspace root
[lightster@local:yo-pdo] $ moor cd

# if the project name is unique to the projects installed,
# you don't need the user/organization name
[lightster@local:workspace] $ moor cd hodor
[lightster@local:hodor] $ moor cd ravens
[lightster@local:ravens] $
```

### Run a docker-compose command
If a project has a docker-compose file, you can run `moor docker-compose` followed by any normal docker-compose subcommands/options:
```ShellSession
[lightster@local:ravens] $ moor docker-compose ps
      Name                   Command            State            Ports          
--------------------------------------------------------------------------------
ravens_rabbitmq_1   docker-entrypoint.sh        Up      15671/tcp, 0.0.0.0:32780
                    rabbi ...                           ->15672/tcp, 25672/tcp,
                                                        4369/tcp, 5671/tcp,     
                                                        0.0.0.0:32781->5672/tcp

[lightster@local:ravens] $ moor docker-compose logs --tail=1
Attaching to ravens_rabbitmq_1
rabbitmq_1  |  * amqp_client

[lightster@local:ravens] $ moor docker-compose run --rm --entrypoint='php' php -v
Starting ravens_rabbitmq_1 ... done
PHP 5.6.24 (cli) (built: Aug 10 2016 20:10:36)
Copyright (c) 1997-2016 The PHP Group
Zend Engine v2.6.0, Copyright (c) 1998-2016 Zend Technologies
    with Xdebug v2.5.5, Copyright (c) 2002-2017, by Derick Rethans

[lightster@local:ravens] $
```

## Pier Usage
The `pier` command takes one or more arguments.  The first argument is the name of the installed project that you want to run commands on.  Any arguments following the project name are passed on to the respective project’s run script.

### Running commands
In the following example, the run command defined by `lightster/ravens` is executed with an argument of `test`
```ShellSession
[lightster@local:workspace] $ pier ravens test
docker-compose run --rm php test
Starting ravens_rabbitmq_1 ... done
PHPUnit 4.8.23 by Sebastian Bergmann and contributors.

...
```
Note that the current working directory can be in the workspace root or any subdirectory of the workspace root.

For an imaginary “web-project”, there might be a `restart` command to restart the web services:
```ShellSession
[lightster@local:ravens] $ pier web-project restart
```
The `restart` option is passed to web-project’s run script.

### Defining commands
Before commands for a project can be ran, the project needs to define the script that is ran by `pier`.

#### Standalone script as a run command
The “run command” for a project can be set via `moor config`.

```ShellSession
[lightster@local:workspace] $ moor config set --project=hodor --defaults pier.run.command "bash docker/pier.sh"
```

In this example, the run command for the project is set to `bash docker.sh`.  Anytime `pier hodor` is ran, `pier` executes `bash docker/pier.sh` within Hodor's root directory on the target machine (the VM if using pier-11)  Since the `pier` command passes any arguments after the project name to the run command,  running:
```
pier hodor test`
```
will run the following on the target machine
```
bash docker/pier.sh test
```

Similarly,
```
pier hodor generate-supervisor-config --hodor-config=path/to/hodor/config.php
```
will run the following on the target machine
```
bash docker/pier.sh generate-supervisor-config --hodor-config=path/to/hodor/config.php
```

Projects can even return their own help if their run command provides a `help` subcommand:
```
pier hodor help
```

#### Makefile as a command
If you want to use a Makefile for your run command, you could set that up via:
```ShellSession
[lightster@local:workspace] $ moor config set --project=hodor --defaults pier.run.command "make"
```
This would cause `pier hodor test` to call `make test`, `pier hodor install` to call `make install`, etc.  The `make` command will run on the target machine.

### Listing installed projects
If you need to get a list of installed projects, you can do so by running `pier` without any additional arguments:
```ShellSession
[lightster@local:workspace] $ pier
Usage:
  pier PROJECT

Available projects:
  hodor
  hub
  pier-cli
  ravens

```
