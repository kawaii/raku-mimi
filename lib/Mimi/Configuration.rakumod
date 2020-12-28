unit class Mimi::Configuration;

use JSON::Fast;

has $.config-file = %*ENV<MIMI_CONFIG_FILE> // "./config.json";

method generate {
    from-json(slurp($!config-file));
}
