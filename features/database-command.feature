Feature: Bail in multisite setup.

  Scenario: Test if multisite in subdirectory
    Given a WP multisite subdirectory install

    When I try `wp database reset --author=dummyuser`
    Then STDERR should contain:
      """
      Error: Multisite is not supported!
      """

Feature: Bail in multisite setup.

  Scenario: Test if multisite in subdomain
    Given a WP multisite subdomain install

    When I try `wp database reset --author=dummyuser`
    Then STDERR should contain:
      """
      Error: Multisite is not supported!
      """

Feature: Test that database command works.

  Scenario: Test author parameter is passed
    Given a WP install

    When I try `wp database reset --author=dummyuser`
    Then STDERR should contain:
      """
      Error: User does not exist.
      """

    When I run `wp user create testsubscriber testsubscriber@gmail.com --role=subscriber`
    And I try `wp database reset --author=testsubscriber`
    Then STDERR should contain:
      """
      Error: User is not administrator.
      """

  Scenario: Administrator user is passed as author
    Given a WP install

    When I run `wp user create testadmin testadmin@gmail.com --role=administrator`
    And I run `wp database reset --author=testadmin`
    Then STDOUT should contain:
      """
      Resetting...
      Success: Database is reset successfully.
      """

    When I run `wp user create testadmin2 testadmin2@gmail.com --role=administrator`
    And I run `wp database reset --author=testadmin2`
    And I run `wp user list --role=administrator --format=count`
    Then STDOUT should be:
      """
      1
      """

    When I run `wp user create testadmin3 testadmin3@gmail.com --role=administrator`
    And I run `wp database reset --author=testadmin3`
    And I run `wp user get testadmin3 --field=email`
    Then STDOUT should be:
      """
      testadmin3@gmail.com
      """

    When I run `wp user create testadmin4 testadmin4@gmail.com --role=administrator --user_pass=testpass@1234`
    And I run `wp user get testadmin4 --field=user_pass`
    And save STDOUT as {USER_PASS}
    And I run `wp database reset --author=testadmin4`
    And I run `wp user get testadmin4 --field=user_pass`
    Then STDOUT should be:
      """
      {USER_PASS}
      """
