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

RSpec::Matchers.define :match_follower do |expected|
  match do |actual|
    expected.follower_type == actual.class.to_s && expected.follower_id == actual.id
  end
end

RSpec::Matchers.define :match_followable do |expected|
  match do |actual|
    expected.followable_type == actual.class.to_s && expected.followable_id == actual.id
  end
end

RSpec::Matchers.define :match_liker do |expected|
  match do |actual|
    expected.liker_type == actual.class.to_s && expected.liker_id == actual.id
  end
end

RSpec::Matchers.define :match_likeable do |expected|
  match do |actual|
    expected.likeable_type == actual.class.to_s && expected.likeable_id == actual.id
  end
end

RSpec::Matchers.define :match_mentioner do |expected|
  match do |actual|
    expected.mentioner_type == actual.class.to_s && expected.mentioner_id == actual.id
  end
end

RSpec::Matchers.define :match_mentionable do |expected|
  match do |actual|
    expected.mentionable_type == actual.class.to_s && expected.mentionable_id == actual.id
  end
end
