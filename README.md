ernilambar/database-command
===========================

Tool to reset WordPress database. This reset WP database but retains given administrator user account.

[![Build Status](https://travis-ci.org/ernilambar/database-command.svg?branch=master)](https://travis-ci.org/ernilambar/database-command)

Quick links: [Installing](#installing) | [Usage](#usage) | [Contributing](#contributing)

## Installing

Installing this package requires WP-CLI v0.23.0 or greater. Update to the latest stable release with `wp cli update`.

Once you've done so, you can install this package with `wp package install git@github.com:ernilambar/database-command.git`

## Usage

`wp database reset --author=<author>`

**Options**

    --author=<author>
        Administrator user you want to keep after reset.

## Contributing

Code and ideas are more than welcome.

Please [open an issue](https://github.com/ernilambar/database-command/issues) with questions, feedback, and violent dissent. Pull requests are expected to include test coverage.
