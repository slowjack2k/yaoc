module Yaoc
  class TransformationCommand
    protected
    attr_accessor :to, :from, :fetcher , :proc, :value_fetcher_proc

    public

    def self.deferred_source
      TransformationDeferredCommand
    end

    def self.default_source
      TransformationCommand
    end

    def self.create(to: nil, from: nil, deferred: false, conversion_proc: nil, fetcher_proc: nil)
      # will be executed in mapper object instance context later through :define_method
      tc_source = deferred ? deferred_source : default_source

      -> (to_convert, result)do
        tc_source.new(to: to, from: from, fetch_method: fetcher, conversion_proc: conversion_proc, fetcher_proc: fetcher_proc).call(to_convert, result)
      end
    end

    def self.fill_result_with_value(result, key, value)
      result.tap{|taped_result| taped_result[key] = value}
    end

    def initialize(to: nil, from: nil, fetch_method: nil, conversion_proc: nil, fetcher_proc: nil)
      self.to = to
      self.from = from
      self.proc = conversion_proc
      self.fetcher = fetch_method
      self.value_fetcher_proc = fetcher_proc || ->(to_convert, fetcher, from){ to_convert.public_send(fetcher, from)}
    end

    def call(to_convert, result)
      unless proc.nil?
        instance_exec(to_convert, result, &proc)
      else
        TransformationCommand.fill_result_with_value(result, to, value(to_convert))
      end
    end

    def value(to_convert)
      value_fetcher_proc.call(to_convert, fetcher, from)
    end
  end
end
