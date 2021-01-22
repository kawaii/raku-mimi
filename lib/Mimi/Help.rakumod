unit module Mimi::Help;

use JSON::Fast;

# TODO; make this an actual object and not lazy slurped raw JSON
our %help is export = from-json(slurp('lib/Mimi/help.json'));
