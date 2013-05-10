RSpec::Matchers.define :be_expired do
  match do |actual|
    backend.check_user_expired(example, actual)
  end
end

