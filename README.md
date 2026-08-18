ernilambar/database-command
===========================

Tool to reset WordPress database. This reset WP database but retains given administrator user account.



Quick links: [Using](#using) | [Installing](#installing)

## Using

~~~
wp database reset --author=<username> [--yes]
~~~

**OPTIONS**

	--author=<username>
		Administrator user you want to keep after reset.

	[--yes]
		Answer yes to the confirmation message.

**EXAMPLES**

    # Reset database and keep `admin` user.
    $ wp database reset --author=admin --yes

## Installing

Installing this package requires WP-CLI v3.0 or greater. Update to the latest stable release with `wp cli update`.

Once you've done so, you can install the latest stable version of this package with:

```bash
wp package install ernilambar/database-command:@stable
```

To install the latest development version of this package, use the following command instead:

```bash
wp package install ernilambar/database-command:dev-main
```


*This README.md is generated dynamically from the project's codebase using `wp scaffold package-readme` ([doc](https://github.com/wp-cli/scaffold-package-command#wp-scaffold-package-readme)). To suggest changes, please submit a pull request against the corresponding part of the codebase.*
