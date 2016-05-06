Feature: Test that database command works.

  Scenario: Test author parameter is passed
    Given a WP install

    When I try `wp database reset`
    Then STDERR should contain:
      """
      Error: --author is required
      """

    When I try `wp database reset --author=`
    Then STDERR should contain:
      """
      Error: User does not exist.
      """

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
