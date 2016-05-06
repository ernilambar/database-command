Feature: Test that database command works.

  Scenario: Hello database command
    Given a WP install

    When I run `wp eval 'echo "Hello test.";'`
    Then STDOUT should contain:
      """
      Hello test.
      """
