RSpec::Matchers.define :be_reg_key do
  match do |actual|
    backend.check_is_reg_key(example, actual)
  end
end

