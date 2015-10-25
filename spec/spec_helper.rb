$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'aspect4r'
require 'rspec'

RSpec.configure do |config|
  config.mock_with :rspec do |c|
    c.syntax = :should
  end

  config.expect_with :rspec do |c|
    c.syntax = :should
  end
end

