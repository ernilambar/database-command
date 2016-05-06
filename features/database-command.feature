Feature: Test that database command works.

  Scenario: Test author parameter is passed
    Given a WP install

    When I run `wp user create testsubscriber testsubscriber@gmail.com --role=subscriber`
    And I run `wp database reset --author=testsubscriber`
    Then STDOUT should contain:
      """
      User is not administrator.
      """
