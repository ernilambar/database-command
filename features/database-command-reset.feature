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
    And I run `wp post generate --count=10`
    And I run `wp database reset --author=testadmin5`
    And I run `wp post list --format=count`
    Then STDOUT should be:
      """
      1
      """

    When I run `wp user create testadmin6 testadmin6@gmail.com --role=administrator`
    And I run `wp option get blogname`
    And save STDOUT as {BLOG_NAME}
    And I run `wp database reset --author=testadmin6`
    And I run `wp option get blogname`
    Then STDOUT should be:
      """
      {BLOG_NAME}
      """

    When I run `wp user create testadmin7 testadmin7@gmail.com --role=administrator`
    And I run `wp user generate --count=10`
    And I run `wp database reset --author=testadmin7`
    And I run `wp user list --format=count`
    Then STDOUT should be:
      """
      1
      """

    When I run `wp user create testadmin8 testadmin8@gmail.com --role=administrator`
    And I run `wp term generate category --count=10`
    And I run `wp database reset --author=testadmin8`
    And I run `wp term list category --format=count`
    Then STDOUT should be:
      """
      1
      """

    When I run `wp post create --post_type=post --post_title='Just a test post' --porcelain`
    And save STDOUT as {SAMPLE_POST_ID}
    And I run `wp comment generate --post_id={SAMPLE_POST_ID}`
    And I run `wp user create testadmin9 testadmin9@gmail.com --role=administrator`
    And I run `wp database reset --author=testadmin9`
    And I run `wp comment list --format=count`
    Then STDOUT should be:
      """
      1
      """

    When I run `wp user create testadmin10 testadmin10@gmail.com --role=administrator`
    And I run `wp option get siteurl`
    And save STDOUT as {SITE_URL}
    And I run `wp database reset --author=testadmin10`
    And I run `wp option get siteurl`
    Then STDOUT should be:
      """
      {SITE_URL}
      """
