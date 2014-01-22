require "yaoc/version"
require 'abstract_type'
require 'yaoc/mapping_base'

Dir[File.join(File.expand_path(__dir__ ), "yaoc/strategies/*.rb")].each { |f| require f }

require 'yaoc/object_mapper'

module Yaoc
  # Your code goes here...
end
