Feature: Test reset behaviour

  Scenario: Valid administrator user is passed as author
    Given a WP install

    When I run `wp user create testadmin2 testadmin2@gmail.com --role=administrator`
    And I run `wp database reset --author=testadmin2 --yes`
    And I run `wp user list --role=administrator --format=count`
    Then STDOUT should be:
      """
      1
      """

    When I run `wp user create testadmin3 testadmin3@gmail.com --role=administrator`
    And I run `wp database reset --author=testadmin3 --yes`
    And I run `wp user get testadmin3 --field=email`
    Then STDOUT should be:
      """
      testadmin3@gmail.com
      """

    When I run `wp user create testadmin4 testadmin4@gmail.com --role=administrator --user_pass=testpass@1234`
    And I run `wp user get testadmin4 --field=user_pass`
    And save STDOUT as {USER_PASS}
    And I run `wp database reset --author=testadmin4 --yes`
    And I run `wp user get testadmin4 --field=user_pass`
    Then STDOUT should be:
      """
      {USER_PASS}
      """

    When I run `wp user create testadmin5 testadmin5@gmail.com --role=administrator`
    And I run `wp post generate --count=10`
    And I run `wp database reset --author=testadmin5 --yes`
    And I run `wp post list --format=count`
    Then STDOUT should be:
      """
      1
      """

    When I run `wp user create testadmin6 testadmin6@gmail.com --role=administrator`
    And I run `wp option get blogname`
    And save STDOUT as {BLOG_NAME}
    And I run `wp database reset --author=testadmin6 --yes`
    And I run `wp option get blogname`
    Then STDOUT should be:
      """
      {BLOG_NAME}
      """

    When I run `wp user create testadmin7 testadmin7@gmail.com --role=administrator`
    And I run `wp user generate --count=10`
    And I run `wp database reset --author=testadmin7 --yes`
    And I run `wp user list --format=count`
    Then STDOUT should be:
      """
      1
      """

    When I run `wp user create testadmin8 testadmin8@gmail.com --role=administrator`
    And I run `wp term generate category --count=10`
    And I run `wp database reset --author=testadmin8 --yes`
    And I run `wp term list category --format=count`
    Then STDOUT should be:
      """
      1
      """

    When I run `wp post create --post_type=post --post_title='Just a test post' --porcelain`
    And save STDOUT as {SAMPLE_POST_ID}
    And I run `wp comment generate --post_id={SAMPLE_POST_ID}`
    And I run `wp user create testadmin9 testadmin9@gmail.com --role=administrator`
    And I run `wp database reset --author=testadmin9 --yes`
    And I run `wp comment list --format=count`
    Then STDOUT should be:
      """
      1
      """

    When I run `wp user create testadmin10 testadmin10@gmail.com --role=administrator`
    And I run `wp option get siteurl`
    And save STDOUT as {SITE_URL}
    And I run `wp database reset --author=testadmin10 --yes`
    And I run `wp option get siteurl`
    Then STDOUT should be:
      """
      {SITE_URL}
      """

  Scenario: Test reset preserves blog_public option
    Given a WP install

    When I run `wp user create testadmin_bp testadmin_bp@gmail.com --role=administrator`
    And I run `wp option set blog_public 0`
    And I run `wp database reset --author=testadmin_bp --yes`
    And I run `wp option get blog_public`
    Then STDOUT should be:
      """
      0
      """

  Scenario: Test reset preserves home and siteurl when customized
    Given a WP install

    When I run `wp user create testadmin_home testadmin_home@gmail.com --role=administrator`
    And I run `wp option set home https://example-home.test`
    And I run `wp option set siteurl https://example-site.test`
    And I run `wp database reset --author=testadmin_home --yes`
    And I run `wp option get home`
    Then STDOUT should be:
      """
      https://example-home.test
      """
    When I run `wp option get siteurl`
    Then STDOUT should be:
      """
      https://example-site.test
      """

  @skip-sqlite
  Scenario: Test reset removes prefixed custom tables but keeps non-prefixed
    Given a WP install

    When I run `wp db query "CREATE TABLE wp_custom_test_reset (id INT PRIMARY KEY)"`
    And I run `wp db query "CREATE TABLE custom_noprefix_reset (id INT PRIMARY KEY)"`
    And I run `wp user create testadmin_ct testadmin_ct@gmail.com --role=administrator`
    And I run `wp database reset --author=testadmin_ct --yes`
    And I run `wp db query "SHOW TABLES LIKE 'wp_custom_test_reset'" --skip-column-names`
    Then STDOUT should not contain:
      """
      wp_custom_test_reset
      """
    When I run `wp db query "SHOW TABLES LIKE 'custom_noprefix_reset'" --skip-column-names`
    Then STDOUT should contain:
      """
      custom_noprefix_reset
      """

  Scenario: Test previous admin is removed after sequential resets
    Given a WP install

    When I run `wp user create adminA adminA@gmail.com --role=administrator`
    And I run `wp database reset --author=adminA --yes`
    And I run `wp user create adminB adminB@gmail.com --role=administrator`
    And I run `wp database reset --author=adminB --yes`
    And I try `wp user get adminA --field=login`
    Then STDERR should contain:
      """
      Invalid user
      """

  @skip-sqlite
  Scenario: Test reset clears activation key and password nag
    Given a WP install

    When I run `wp user create testadmin_meta testadmin_meta@gmail.com --role=administrator`
    And I run `wp eval 'update_user_meta( get_user_by( "login", "testadmin_meta" )->ID, "default_password_nag", true );'`
    And I run `wp db query "UPDATE wp_users SET user_activation_key='testkey123' WHERE user_login='testadmin_meta'"`
    And I run `wp database reset --author=testadmin_meta --yes`
    And I run `wp db query "SELECT user_activation_key FROM wp_users WHERE user_login='testadmin_meta'" --skip-column-names`
    Then STDOUT should not contain:
      """
      testkey123
      """
    When I run `wp eval 'echo get_user_meta( get_user_by( "login", "testadmin_meta" )->ID, "default_password_nag", true ) ? "1" : "0";'`
    Then STDOUT should be:
      """
      0
      """
