require "yaoc/version"

Dir[File.join(File.expand_path(__dir__ ), "yaoc/helper/*.rb")].each { |f| require f }

require 'yaoc/mapping_base'
require 'yaoc/transformation_command'
require 'yaoc/transformation_deferred_command'
require 'yaoc/mapping_to_class'

Dir[File.join(File.expand_path(__dir__ ), "yaoc/strategies/*.rb")].each { |f| require f }

require 'yaoc/converter_builder'
require 'yaoc/object_mapper'
require 'yaoc/mapper_chain'

module Yaoc

end
