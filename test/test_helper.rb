require 'rubygems'
require 'active_support'
require 'active_support/test_case'
require 'test/unit'

# required to avoid errors
module ActiveRecord
  class Base; end
end
require 'handler'

