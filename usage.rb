config.after(:each) do
  Toughen.display_class_instance_variables
end

# OR
config.after(:each) do
  Toughen.fail_if_class_instance_variables
end