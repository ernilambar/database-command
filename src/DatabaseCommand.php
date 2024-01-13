<?php

namespace Nilambar\WP_CLI_Database\DatabaseCommand;

use WP_CLI;
use WP_CLI_Command;

class DatabaseCommand extends WP_CLI_Command {

	/**
	 * Reset database content except one administrator user.
	 *
	* ## OPTIONS
	*
	 * --author=<username>
	 * : Administrator user you want to keep after reset
	*
	 * ## EXAMPLES
	 *
	 *     # Reset database and keep `admin` user
	 *     $ wp database reset --author=admin
	 *
	 * @when after_wp_load
	 *
	 * @param array $args       Indexed array of positional arguments.
	 * @param array $assoc_args Associative array of associative arguments.
	 */
	public function reset( $args, $assoc_args ) {
		// Bail if multisite.
		if ( \is_multisite() ) {
			WP_CLI::error( 'Multisite is not supported!' );
		}

		$defaults = array(
			'author' => null,
		);

		$assoc_args = \wp_parse_args( $assoc_args, $defaults );

		$author = $assoc_args['author'];

		$author_obj = \get_user_by( 'login', $author );

		if ( false === $author_obj ) {
			WP_CLI::error( 'User does not exist.' );
		}

		if ( true !== \user_can( $author_obj, 'manage_options' ) ) {
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
		WP_CLI::log( 'Resetting...' );

		// We dont want email notification.
		if ( ! function_exists( 'wp_new_blog_notification' ) ) {
			function wp_new_blog_notification() {
				// Silence is golden.
			}
		}

		require_once ABSPATH . '/wp-admin/includes/upgrade.php';

		$blogname    = \get_option( 'blogname' );
		$blog_public = \get_option( 'blog_public' );
		$siteurl     = \get_option( 'siteurl' );

		global $wpdb;

		$tables = $wpdb->get_col( $wpdb->prepare( 'SHOW TABLES LIKE %s', $wpdb->esc_like( $wpdb->prefix ) . '%' ) );

		foreach ( $tables as $table ) {
			$wpdb->query( sprintf( 'DROP TABLE %s', esc_attr( $table ) ) ); // phpcs:ignore WordPress.DB.PreparedSQL.NotPrepared
		}

		// Set site URL.
		WP_CLI::set_url( $siteurl );

		$result = \wp_install( $blogname, $user->user_login, $user->user_email, $blog_public );

		if ( \is_wp_error( $result ) ) {
			WP_CLI::error( 'Reset failed (' . WP_CLI::error_to_string( $result ) . ').' );
		}

		if ( ! empty( $GLOBALS['wpdb']->last_error ) ) {
			WP_CLI::error( 'Resetting produced database errors, and may have partially or completely failed.' );
		}

		$user_id = isset( $result['user_id'] ) ? absint( $result['user_id'] ) : 0;

		$wpdb->query( $wpdb->prepare( "UPDATE $wpdb->users SET user_pass = %s, user_activation_key = '' WHERE ID = %d", $user->user_pass, $user_id ) );

		// Fix password update nag.
		\update_user_meta( $user_id, 'default_password_nag', false );

		\wp_clear_auth_cookie();

		WP_CLI::success( 'Database is reset successfully.' );
	}
}
