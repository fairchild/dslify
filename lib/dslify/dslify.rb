# Quick 1-file dsl accessor
module Dslify
  module ClassMethods
    def default_options(hsh={})
      @default_dsl_options ||= hsh
    end
  end
  
  module InstanceMethods
    def __h(hsh={})
      @__h ||= hsh
    end
    def default_dsl_options
      self.class.default_options
    end
    def dsl_options(h={})
      if !h.empty?
        @__h = self.class.default_options.merge(h)
      else
        __h(self.class.default_options)
      end
    end
    def set_vars_from_options(h={})
      h.each{|k,v|send k.to_sym, v } unless h.empty?
    end
    def add_method(meth)
      # instance_eval <<-EOM
      #   def #{meth}(n=nil)
      #     puts "called #{meth}(\#\{n\}) from \#\{self\}"
      #     n ? (__h[:#{meth}] = n) : __h[:#{meth}]
      #   end
      #   def #{meth}=(n)
      #     __h[:#{meth}] = n
      #   end
      # EOM
    end
    
    # If using parenting gem, and object has a parent, check parent for the option.
    def check_parent_for_dsl_option(m)
      if defined?(parent) and parent  and parent.respond_to?(:dsl_options)
          parent.dsl_options[m]
      end
    end
    
    def check_for_parent_defaults(m)
      if defined?(parent) and parent  and parent.class.respond_to?(:default_options)
          parent.class.default_options[m]
      end
    end
    
    def method_missing(m, *args, &block)
      if block
        if args.empty?
          (args[0].class == self.class) ? args[0].instance_eval(&block) : super
        else
          inst = args[0]
          inst.instance_eval(&block)
          __h[m] = inst
        end
      else
        if args.empty?
          __h[m.to_sym] || check_parent_for_dsl_option(m) || self.class.default_options[m] || check_for_parent_defaults(m) #|| super #FIXME  should be called when nothing matches.  breaks to many things for now, fix later
        else
          clean_meth = m.to_s.gsub(/\=/,"").to_sym
          __h[clean_meth] = (args.size > 1 ? args : args[0])
        end
      end
    end
  end
  
  def self.included(receiver)
    receiver.extend         ClassMethods
    receiver.send :include, InstanceMethods
  end
end