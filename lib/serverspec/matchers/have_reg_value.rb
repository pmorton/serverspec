RSpec::Matchers.define :have_reg_value do |value|
  match do |key|
    if @type.nil? && @value.nil?
      backend.check_is_reg_value(example, key)
    elsif !@type.nil?  && !@value.nil?
      raise NotImplementedError.new('Check only one condition at a time')
    elsif @type
      backend.check_reg_type(example, key, value , @type)
    else
      backend.check_reg_value(example, key , value, @value)
    end
  end

  chain :type do |type|
    @type = type
  end

  chain :value do |value|
    @value = value
  end
end

