Feature: Test reset behaviour

  Scenario: Valid administrator user is passed as author
    Given a WP install

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

    When I run `wp user create testadmin5 testadmin5@gmail.com --role=administrator`
    And I run `wp post create --post_title='Sample Post 1' --post_status=publish`
    And I run `wp post create --post_title='Sample Post 2' --post_status=publish`
    And I run `wp database reset --author=testadmin5`
    And I run `wp post list --format=count`
    Then STDOUT should be:
      """
      1
      """

