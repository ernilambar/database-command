Feature: Test that database command works.

  Scenario: Check author param in the command
    Given a WP install

    When I run `wp database reset`
    Then STDOUT should contain:
      """
      --author is required
      """
