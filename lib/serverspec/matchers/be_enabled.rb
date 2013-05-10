RSpec::Matchers.define :be_enabled do
  match do |actual|
    case @type
    when :user
    	backend.check_user_enabled(example, actual)
    else
      backend.check_enabled(example, actual)
    end
  end
  chain :user do
  	@type = :user
  end
end
