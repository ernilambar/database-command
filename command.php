<?php

namespace Nilambar\WP_CLI_Database\DatabaseCommand;

use WP_CLI;

if ( ! class_exists( '\WP_CLI' ) ) {
	return;
}

$wpcli_database_command_autoloader = __DIR__ . '/vendor/autoload.php';

if ( file_exists( $wpcli_database_command_autoloader ) ) {
	require_once $wpcli_database_command_autoloader;
}

WP_CLI::add_command( 'database reset', [ DatabaseCommand::class, 'reset' ] );
WP_CLI::add_command( 'database test', [ DatabaseCommand::class, 'test' ] );
