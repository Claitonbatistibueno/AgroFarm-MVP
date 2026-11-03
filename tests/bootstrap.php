<?php
// Unit tests load only the pure code (no web server, no database).
define('FARM_ROOT', dirname(__DIR__));
define('FARM_BOOTSTRAPPED', true);   // lets vet_ai.php be included
define('APP_DEBUG', true);
require_once FARM_ROOT . '/lib/helpers.php';
require_once FARM_ROOT . '/lib/db.php';
require_once FARM_ROOT . '/vet_ai.php';
