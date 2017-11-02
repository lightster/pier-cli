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
