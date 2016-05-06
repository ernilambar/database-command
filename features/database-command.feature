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
    Then STDOUT should contain:
      """
      1
      """

    When I run `wp user create testadmin3 testadmin3@gmail.com --role=administrator`
    And I run `wp database reset --author=testadmin3`
    And I run `wp user get testadmin3 --field=email`
    Then STDOUT should contain:
      """
      testadmin3@gmail.com
      """
