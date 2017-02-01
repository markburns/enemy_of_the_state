

# Example sets some state
class SomeObject
  def self.asdf
    @a = 1
  end
end

SomeObject.asdf

config.after(:each) do
  EnemyOfTheState.display
end

# OR
config.after(:each) do
  EnemyOfTheState.fail
end