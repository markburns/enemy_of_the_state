# this code just uses delfos to find relevant application code - 
# will extract into own gem
require "delfos"
require "delfos/method_logging"

Delfos.application_directories = [File.expand_path(".")]
require "enemy_of_the_state"
