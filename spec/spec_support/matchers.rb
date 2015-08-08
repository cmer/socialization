RSpec::Matchers.define :be_a_public_method_of do |obj|
  match do |actual|
    method = RUBY_VERSION.match(/^1\.8/) ? actual.to_s : actual.to_s.to_sym
    obj.public_methods.include?(method)
  end

  failure_message do |actual|
    "expected that #{actual} would be a public method of #{actual.class}"
  end

  failure_message_when_negated do |actual|
    "expected that #{actual} would not be a public method of #{actual.class}"
  end

  description do
    "be a public method"
  end
end
