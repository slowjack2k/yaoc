require "yaoc/version"

require 'scoped_storage'

require 'yaoc/helper/struct_hash_constructor'
require 'yaoc/helper/to_proc_delegator'

require 'yaoc/mapper_registry'
require 'yaoc/mapping_base'
require 'yaoc/transformation_command'
require 'yaoc/transformation_deferred_command'
require 'yaoc/mapping_to_class'

Dir[File.join(File.expand_path(__dir__), "yaoc/strategies/*.rb")].each { |f| require f }

require 'yaoc/converter_builder'
require 'yaoc/object_mapper'
require 'yaoc/many_to_one_mapper_chain'
require 'yaoc/one_to_many_mapper_chain'

module Yaoc
end
