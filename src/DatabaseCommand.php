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
	 * : Administrator user you want to keep after reset.
	*
	 * ## EXAMPLES
	 *
	 *     # Reset database and keep `admin` user.
	 *     $ wp database reset --author=admin
	 *
	 * @since 1.0.0
	 *
	 * @return void
	 *
	 * @when after_wp_load
	 *
	 * @param array<int, string>  $args       Indexed array of positional arguments.
	 * @param array<string, mixed> $assoc_args Associative array of associative arguments.
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

		if ( is_string( $author ) ) {
			$author = trim( $author );
		}

		if ( empty( $author ) ) {
			WP_CLI::error( 'User does not exist.' );
		}

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
	 * @since 1.0.0
	 *
	 * @return void
	 *
	 * @access private
	 *
	 * @param \WP_User $user WP_User object.
	 */
	private function reset_callback( \WP_User $user ) {
		WP_CLI::log( 'Resetting...' );

		// We don't want email notification.
		if ( ! function_exists( 'wp_new_blog_notification' ) ) {
			/**
			 * @since 1.0.0
			 *
			 * @return void
			 */
			// @phpstan-ignore function.inner
			function wp_new_blog_notification() {
				// Silence is golden.
			}
		}

		require_once ABSPATH . '/wp-admin/includes/upgrade.php';

		$blogname    = \get_option( 'blogname' );
		$blog_public = \get_option( 'blog_public' );
		$siteurl     = \get_option( 'siteurl' );
		$home        = \get_option( 'home' );

		/**
		 * WordPress database access abstraction object.
		 *
		 * @var \wpdb $wpdb
		 */
		global $wpdb;

		$prefix = $wpdb->esc_like( $wpdb->prefix );

		$tables = $wpdb->get_col( "SHOW TABLES LIKE '{$prefix}%'" ); // phpcs:ignore WordPress.DB.PreparedSQL

		foreach ( $tables as $table ) {
			$wpdb->query( "DROP TABLE $table" ); // phpcs:ignore WordPress.DB.PreparedSQL

			if ( ! empty( $wpdb->last_error ) ) {
				WP_CLI::error( "Failed to drop table {$table} ({$wpdb->last_error})." );
			}
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

		// Restore siteurl and home if they were customized.
		if ( $siteurl ) {
			\update_option( 'siteurl', $siteurl );
		}
		if ( $home ) {
			\update_option( 'home', $home );
		}

		$user_id = isset( $result['user_id'] ) ? absint( $result['user_id'] ) : 0;

		$wpdb->update(
			$wpdb->users,
			array(
				'user_pass'           => $user->user_pass,
				'user_activation_key' => '',
			),
			array( 'ID' => $user_id ),
			array( '%s', '%s' ),
			array( '%d' )
		);

		// Fix password update nag.
		\update_user_meta( $user_id, 'default_password_nag', false );

		\wp_clear_auth_cookie();

		WP_CLI::success( 'Database is reset successfully.' );
	}
}
