require "yaoc/version"

require 'yaoc/helper/struct_hash_constructor'
require 'yaoc/helper/to_proc_delegator'
require 'yaoc/helper/thread_local_storage'
require 'yaoc/helper/thread_global_storage'
require 'yaoc/helper/scope'

require 'yaoc/mapper_registry'
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
