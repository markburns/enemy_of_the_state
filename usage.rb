require_relative "app/example_code"
require_relative "enemy_of_the_state"

EnemyOfTheState.application_directories = [File.expand_path("./app")]
EnemyOfTheState.display 
# OR 
# EnemyOfTheState.fail
