require 'rubygems'
require 'active_support'
require 'active_support/test_case'
require 'minitest/autorun'

# required to avoid errors
module ActiveRecord
  class Base; end
end
require 'handler'

