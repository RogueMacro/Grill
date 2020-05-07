# bpm
Beef package manager

### Note: This readme is still in the works

## How to use

You can run `bpm <command> [arguments]` from the command line to run a specific command.

You can also run `bpm` from the command line or start `bpm.exe` to open the bpm shell.
In the shell you can run different commands, i.e. `bpm> install <package>`.

## Arguments

Arguments prefixed with a `-` (dash) are flag arguments, which doesn't have a value. Flag arguments come last after value arguments.
All other arguments (both required and optional) are value arguments. Their value can be passed at the index like shown in their syntax, or by doing `<argument>=<value>` somewhere after indexed arguments i.e. `bpm install package=<package name>`.

`<argument>` means the argument is required.
`[argument]` means the argument is optional.

## Commands

`bpm install <package> [-global] [-force]`

Clones a package repository to your computer.

- package: The name of the package
- global: Installs the package for all users.
- force: Installs the package without any prompts.

`bpm upgrade <package> [version] [-global]`

Installs a new version of the package.

- package: The name of the package
- version: The new version to install. (Not supported yet)
- global: Installs the package for all users.
