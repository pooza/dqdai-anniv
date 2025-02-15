module DqdaiAnniv
  class Model
    include Package

    def initialize(params)
      @params = params.deep_stringify_keys
    end

    def method_missing(method, *args)
      return @params[method.to_s] if args.empty?
      return super
    end

    def respond_to_missing?(method, *args)
      return args.empty? if args.is_a?(Array)
      return super
    end
  end
end
