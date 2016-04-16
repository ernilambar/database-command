<?php

class Run_Database_Command extends WP_CLI_Command {

    /**
     * Reset database content except one administrator user login.
     *
     * ## OPTIONS
     *
     * --author=<username>
     * : Administrator user you want to keep after reset. (Required)
     *
     * ## EXAMPLE
     * # Reset database and keep `admin` user.
     * wp database reset --author=admin
     */
    public function reset( $args, $assoc_args ) {

    	$defaults = array(
    		'author' => null,
		);
    	$assoc_args = wp_parse_args( $assoc_args, $defaults );

        $author = '';
        if ( isset( $assoc_args['author'] ) && ! empty( $assoc_args['author'] ) ) {
        	$author = $assoc_args['author'];
        }
        if ( empty( $author ) ) {
	        WP_CLI::error( '--author is required' );
        }
        $author_obj = get_user_by( 'login', $author );
        if ( false === username_exists( $author ) ) {
	        WP_CLI::error( 'User does not exist.' );
        }
        if ( ! user_can( $author_obj, 'administrator' )  ) {
	        WP_CLI::error( 'User is not administrator.' );
        }
        $this->reset_callback( $author_obj );

    }

    /**
     * Reset database.
     *
     * @access private
     *
     * @param WP_User $user WP_User object.
     */
    private function reset_callback( $user ) {

    	WP_CLI::success( 'Resetting...' );

    	// We dont want email notification.
    	if ( ! function_exists( 'wp_new_blog_notification' ) ) {
    		function wp_new_blog_notification() {
				// Silence is golden.
    		}
    	}
    	require_once( ABSPATH . '/wp-admin/includes/upgrade.php' );

		$blogname    = get_option( 'blogname' );
		$admin_email = get_option( 'admin_email' );
		$blog_public = get_option( 'blog_public' );
		$siteurl     = get_option( 'siteurl' );

    	global $wpdb;

    	$prefix = str_replace( '_', '\_', $wpdb->prefix );

    	$tables = $wpdb->get_col( "SHOW TABLES LIKE '{$prefix}%'" );
    	foreach ( $tables as $table ) {
    		$wpdb->query( "DROP TABLE $table" );
    	}

    	// Set site URL.
    	WP_CLI::set_url( $siteurl );

        $result = wp_install( $blogname, $user->user_login, $user->user_email, $blog_public );
        if ( is_wp_error( $result ) ) {
        	WP_CLI::error( 'Reset failed (' . WP_CLI::error_to_string( $result ) . ').' );
        }
        if ( ! empty( $GLOBALS['wpdb']->last_error ) ) {
        	WP_CLI::error( 'Resetting produced database errors, and may have partially or completely failed.' );
        }
        extract( $result, EXTR_SKIP );

        $query = $wpdb->prepare( "UPDATE $wpdb->users SET user_pass = %s, user_activation_key = '' WHERE ID = %d", $user->user_pass, $user_id );
        $wpdb->query( $query );

        if ( get_user_meta( $user_id, 'default_password_nag' ) ) {
        	update_user_meta( $user_id, 'default_password_nag', false );
        }

        if ( get_user_meta( $user_id, $wpdb->prefix . 'default_password_nag' ) ) {
        	update_user_meta( $user_id, $wpdb->prefix . 'default_password_nag', false );
        }

        wp_clear_auth_cookie();

        WP_CLI::success( 'Database is reset successfully.' );

    }

}

WP_CLI::add_command( 'database', 'Run_Database_Command' );
