module Yaoc
  module MapperRegistry
    module_function

    def scope_storage(new_storage)
      @scope = Helper::Scope.new("mappings", new_storage)
    end

    def scope
      @scope ||= Helper::Scope.new("mappings")
    end

    def add(key, mapper)
      scope[key.to_sym] = mapper
    end

    def for(key)
      scope[key.to_sym]
    end

  end
end