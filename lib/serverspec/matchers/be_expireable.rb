RSpec::Matchers.define :be_expireable do
  match do |actual|
    backend.check_user_expireable(example, actual)
  end
end

