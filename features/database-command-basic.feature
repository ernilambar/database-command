Feature: Basic tests

  Scenario: Test if multisite in subdirectory
    Given a WP multisite subdirectory install

    When I try `wp database reset --author=dummyuser`
    Then STDERR should be:
      """
      Error: Multisite is not supported!
      """

  Scenario: Test if multisite in subdomain
    Given a WP multisite subdomain install

    When I try `wp database reset --author=dummyuser`
    Then STDERR should be:
      """
      Error: Multisite is not supported!
      """

  Scenario: Test author parameter is not passed
    Given a WP install

    When I try `wp database reset`
    Then STDERR should contain:
      """
      Error: Parameter errors:
       missing --author parameter (Administrator user you want to keep after reset.)
      """

  Scenario: Test author parameter is passed but non-existent user
    Given a WP install

    When I try `wp database reset --author=dummyuser`
    Then STDERR should be:
      """
      Error: User does not exist.
      """

  Scenario: Test author parameter is passed but non-administrator user
    Given a WP install

    When I run `wp user create testsubscriber testsubscriber@gmail.com --role=subscriber`
    And I try `wp database reset --author=testsubscriber`
    Then STDERR should be:
      """
      Error: User is not administrator.
      """

  Scenario: Administrator user is passed as author
    Given a WP install

    When I run `wp user create testadmin testadmin@gmail.com --role=administrator`
    And I run `wp database reset --author=testadmin`
    Then STDOUT should contain:
      """
      Success: Database is reset successfully.
      """
