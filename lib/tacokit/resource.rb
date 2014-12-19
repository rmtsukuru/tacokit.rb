require 'forwardable'

module Tacokit
  class Resource
    SPECIAL_METHODS = Set.new(%w(client fields))
    attr_reader :_client
    attr_reader :_fields
    attr_reader :attrs
    alias to_hash attrs
    alias to_h attrs
    include Enumerable
    extend Forwardable

    def_delegators :@_fields, :fetch, :keys, :key?, :has_key?, :include?, :any?

    def initialize(client, data = {})
      @_client = client
      @attrs = {}
      @_metaclass = (class << self; self; end)
      @_fields = Set.new
      data.each do |key, value|
        @_fields << key
        @attrs[key.to_sym] = process_value(value)
      end
      @_metaclass.send(:attr_accessor, *data.keys)
    end

    def process_value(value)
      case value
      when Hash then self.class.new(@_client, value)
      when Array then value.map { |v| process_value(v) }
      else value
      end
    end

    def each(&block)
      @attrs.each(&block)
    end

    def [](method)
      send(method.to_sym)
    rescue NoMethodError
      nil
    end

    def []=(method, value)
      send("#{method}=", value)
    rescue NoMethodError
      nil
    end

    def self.attr_accessor(*attrs)
      attrs.each do |attribute|
        class_eval do
          define_method attribute do
            @attrs[attribute.to_sym]
          end

          define_method "#{attribute}=" do |value|
            @attrs[attribute.to_sym] = value
          end

          define_method "#{attribute}?" do
            !!@attrs[attribute.to_sym]
          end
        end
      end
    end

    ATTR_SETTER    = '='.freeze
    ATTR_PREDICATE = '?'.freeze

    # Provides access to a resource's attributes.
    def method_missing(method, *args)
      attr_name, suffix = method.to_s.scan(/([a-z0-9\_]+)(\?|\=)?$/i).first
      if suffix == ATTR_SETTER
        @_metaclass.send(:attr_accessor, attr_name)
        @_fields << attr_name.to_sym
        send(method, args.first)
      elsif attr_name && @_fields.include?(attr_name.to_sym)
        value = @attrs[attr_name.to_sym]
        case suffix
        when nil
          @_metaclass.send(:attr_accessor, attr_name)
          value
        when ATTR_PREDICATE then !!value
        end
      elsif suffix.nil? && SPECIAL_METHODS.include?(attr_name)
        instance_variable_get "@_#{attr_name}"
      elsif attr_name && !@_fields.include?(attr_name.to_sym)
        nil
      else
        super
      end
    end

    def inspect
      to_attrs.respond_to?(:pretty_inspect) ? to_attrs.pretty_inspect : to_attrs.inspect
    end

    def to_attrs
      hash = self.attrs.clone
      hash.keys.each do |k|
        if hash[k].is_a?(Tacokit::Resource)
          hash[k] = hash[k].to_attrs
        elsif hash[k].is_a?(Array) && hash[k].all?{|el| el.is_a?(Tacokit::Resource)}
          hash[k] = hash[k].collect{|el| el.to_attrs}
        end
      end
      hash
    end

  end
end