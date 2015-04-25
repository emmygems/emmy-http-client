$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'emmy_http/client'

RSpec.configure do |c|
  c.fail_fast = true
end
