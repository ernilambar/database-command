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

  Scenario: Test empty author parameter value
    Given a WP install

    When I try `wp database reset --author=""`
    Then STDERR should be:
      """
      Error: User does not exist.
      """

  Scenario: Test whitespace-only author parameter value
    Given a WP install

    When I try `wp database reset --author="   "`
    Then STDERR should be:
      """
      Error: User does not exist.
      """

  Scenario: Test reset when multiple administrators exist
    Given a WP install

    When I run `wp user create firstadmin firstadmin@gmail.com --role=administrator`
    And I run `wp user create secondadmin secondadmin@gmail.com --role=administrator`
    And I run `wp database reset --author=secondadmin`
    And I run `wp user list --role=administrator --format=count`
    Then STDOUT should be:
      """
      1
      """

  Scenario: Test reset accepts administrator usernames with punctuation
    Given a WP install

    When I run `wp user create admin.name admin.name@gmail.com --role=administrator`
    And I run `wp database reset --author=admin.name`
    Then STDOUT should contain:
      """
      Success: Database is reset successfully.
      """

  @skip-sqlite
  Scenario: Test reset fails when wp_install returns an error
    Given a WP install
    And a wp-content/mu-plugins/simulate-install-failure.php file:
      """
      <?php
      function wp_install( $blog_title, $user_name, $user_email, $is_public, $deprecated = '', $user_password = '', $language = '' ) {
      	return new WP_Error( 'simulated_install_error', 'Simulated wp_install failure.' );
      }
      """

    When I run `wp user create installfailadmin installfailadmin@gmail.com --role=administrator`
    And I try `wp database reset --author=installfailadmin`
    Then STDERR should contain:
      """
      Error: Reset failed
      """

  Scenario: Test reset accepts a custom role with manage_options capability
    Given a WP install

    When I run `wp role create customadmin "Custom Admin"`
    And I run `wp user create customadminuser customadminuser@gmail.com --role=customadmin`
    And I run `wp eval 'get_role( "customadmin" )->add_cap( "manage_options" );'`
    And I run `wp database reset --author=customadminuser`
    Then STDOUT should contain:
      """
      Success: Database is reset successfully.
      """

  Scenario: Test repeated reset with the same administrator
    Given a WP install

    When I run `wp user create repeatadmin repeatadmin@gmail.com --role=administrator`
    And I run `wp database reset --author=repeatadmin`
    And I run `wp database reset --author=repeatadmin`
    Then STDOUT should contain:
      """
      Success: Database is reset successfully.
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

  Scenario: Test missing author parameter is caught before multisite check runs
    Given a WP multisite subdirectory install

    When I try `wp database reset`
    Then STDERR should contain:
      """
      missing --author parameter
      """

  Scenario: Test author with leading/trailing whitespace is trimmed
    Given a WP install

    When I run `wp user create spacedadmin spacedadmin@gmail.com --role=administrator`
    And I run `wp database reset --author=" spacedadmin "`
    Then STDOUT should contain:
      """
      Success: Database is reset successfully.
      """

  @skip-sqlite
  Scenario: Test author lookup is case-insensitive on collations that support it
    Given a WP install

    When I run `wp user create caseadmin caseadmin@gmail.com --role=administrator`
    And I run `wp database reset --author=CASEADMIN`
    Then STDOUT should contain:
      """
      Success: Database is reset successfully.
      """

  Scenario: Test author as user ID does not match a username
    Given a WP install

    When I run `wp user create idadmin idadmin@gmail.com --role=administrator`
    And I run `wp user get idadmin --field=ID`
    And save STDOUT as {USER_ID}
    And I try `wp database reset --author={USER_ID}`
    Then STDERR should be:
      """
      Error: User does not exist.
      """

  Scenario: Test author as email does not match a username
    Given a WP install

    When I run `wp user create emailadmin emailadmin@gmail.com --role=administrator`
    And I try `wp database reset --author=emailadmin@gmail.com`
    Then STDERR should be:
      """
      Error: User does not exist.
      """

  Scenario: Test custom role without manage_options capability fails
    Given a WP install

    When I run `wp role create customnorole "Custom NoRole"`
    And I run `wp user create noroleuser noroleuser@gmail.com --role=customnorole`
    And I try `wp database reset --author=noroleuser`
    Then STDERR should be:
      """
      Error: User is not administrator.
      """

  Scenario: Test editor role cannot be used as author
    Given a WP install

    When I run `wp user create testeditor testeditor@gmail.com --role=editor`
    And I try `wp database reset --author=testeditor`
    Then STDERR should be:
      """
      Error: User is not administrator.
      """

  Scenario: Test help shows author parameter
    Given an empty directory

    When I try `PAGER= wp help database reset`
    Then STDOUT should contain:
      """
      --author
      """
