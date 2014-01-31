module Yaoc
  module MapperRegistry
    module_function

    def scope
      @scope ||= Helper::Scope.new("mappings")
    end

    def register(key, mapper)
      scope[key.to_sym] = mapper
    end

    def for(key)
      scope[key.to_sym]
    end

  end
end