module Ruby
  class Node
    module Traversal
      def select(*args, &block)
        result = []
        result << self if matches?(args.dup, &block)
        children = (prolog.try(:elements).to_a || []) + nodes
        children.flatten.compact.inject(result) do |result, node|
          if node.class.to_s == 'Symbol'
            return result
          end
          result + node.select(*args, &block)
        end
      end

      def matches?(args, &block)
        conditions = args.last.is_a?(::Hash) ? args.pop : {}
        conditions[:is_a] = args unless args.empty?

        conditions.inject(!conditions.empty?) do |result, (type, value)|
          result && case type
        when :is_a
          has_type?(value)
        when :class
          is_instance_of?(value)
        when :token
          has_token?(value)
        when :value
          has_value?(value)
        when :identifier
          has_identifier?(value)
        when :const
          has_const?(value)
        when :block
          has_block?
        when :namespace          
          has_namespace?(value)
        when :superclass
          superclass?(value)
        when :args
          args?(value)                        
        when :params
          params?(value)                        
        when :block_params
          block_params?(value)                        
        when :pos, :position
          position?(value)
        when :right_of
          right_of?(value)
        when :left_of
          left_of?(value)
        end
      end && (!block_given? || block.call(self))
    end

    def has_type?(klass)
      case klass
      when ::Array
        klass.each { |klass| return true if has_type?(klass) } and false
      else
        is_a?(klass) # allow to pass a symbol or string, too
      end
    end

    # TODO: Needs major refactoring!
    def args?(value)
      found = 0
      if respond_to? :arguments
        args = arguments.elements
        args.each do |arg|    
          argum = arg.arg
          argument = get_arg(argum) 
          argument = argument.to_sym if argum.class == Ruby::Symbol
          argument = argument.to_i if argum.class == Ruby::Integer
          argument = argument.to_f if argum.class == Ruby::Float
          value.each do |v|            
            v = v[:array] if v.respond_to?(:has_key?) && v[:array]              
            found += 1 if argument == v
          end
        end
        return found == value.size
      end
      false
    end                             

    # TODO: Needs major refactoring!
    def get_arg(arg) 
      if arg.respond_to? :arg
        get_arg(arg.arg)
      elsif arg.respond_to? :token
        get_token(arg)
      elsif arg.respond_to? :identifier
        get_identifier(arg)
      elsif arg.respond_to? :key
        get_hash_item(arg)
      elsif arg.respond_to? :elements
        e = arg.elements
        if e.size == 1
          return get_arg(e[0])
        end 

        if arg.class == Ruby::Hash 
          get_hash(e)
        elsif arg.class == Ruby::Array
          get_array(e)
        end           
      else
        puts "unknown element type"
      end
    end

    # TODO: Needs major refactoring!
    def get_param(arg) 
      if arg.respond_to? :token
        get_token(arg)
      elsif arg.respond_to? :identifier
        get_identifier(arg)
      elsif arg.respond_to? :key
        get_hash_item(arg)
      elsif arg.respond_to? :elements
        e = arg.elements
        if e.size == 1
          get_param(e[0])
        end
        if arg.class == Ruby::Hash 
          get_hash(e)
        elsif arg.class == Ruby::Array
          get_array(e)
        end           
      else
        puts "unknown element type"
      end        
    end


    def get_array(args)
      arr = []  
      args.each do |arg|
         arr << get_arg(arg)
      end
      arr
    end 

    def get_hash(args)
      hash = {}
      args.each do |arg|
         hash_val = get_arg(arg)
         hash.merge!(hash_val)
      end
      hash
    end 


    # TODO: Needs major refactoring!
    def block_params?(value)
      found = 0 
      if respond_to? :block
        p = self.block 
        parameters = p.params.elements
        parameters.each do |param| 
          parameter = get_param(param.param) 
          value.each do |v|                       
            v = v[:array] if v.respond_to?(:has_key?) && v[:array]            
            found += 1 if parameter == v
          end
        end  
        return found == value.size
      end
      false
    end

    # TODO: Needs major refactoring! 
    def params?(value)
      found = 0 
      if respond_to? :params
        parameters = params.elements
        parameters.each do |param| 
          parameter = get_param(param.param) 
          value.each do |v|  
            v = v[:array] if v.respond_to?(:has_key?) && v[:array]
            found += 1 if parameter == v
          end
        end  
        return found == value.size
      end
      false
    end

    def get_hash_item(arg)
      key = get_identifier(arg.key) if key.respond_to? :identifier
      key = get_identifier(arg.key).to_sym  if arg.key.class == Ruby::Symbol
      key = get_token(arg.key) if arg.key.class == Ruby::Variable
      value = get_token(arg.value)
      value = value.to_i if arg.value.class == Ruby::Integer
      value = value.to_sym if arg.value.class == Ruby::Symbol
      value = value.to_f if arg.value.class == Ruby::Float
      return {key => value}
    end

    def get_identifier(arg)
      get_token(arg.identifier)
    end
    
    def get_token(arg)
      return arg.elements[0].token if arg.class == Ruby::String        
      arg.token
    end

    def is_instance_of?(klass)
      case klass
      when ::Array
        klass.each { |klass| return true if has_type?(klass) } and false
      else
        instance_of?(klass) # allow to pass a symbol or string, too
      end
    end

    def has_token?(token)
      case token
      when ::Array
        type.each { |type| return true if has_token?(token) } and false
      else
        self.token == token
      end if respond_to?(:token)
    end

    def has_const?(value)
      if respond_to?(:const)
        if namespace?(value)
          name = value.split('::').last
          return self.const.identifier.token == name
        end
      end
      false
    end

    def has_block?
      respond_to? :block
    end

    def superclass?(value)      
      if class_or_module?
        ns = get_full_namespace(self.super_class) 
        return ns == value
      end
      false      
    end

    def has_namespace?(value)
      if respond_to?(:namespace)
        return self.namespace.identifier.token == value
      end
      false
    end


    def has_identifier?(value)
      if respond_to?(:identifier)
        id = self.identifier
        
        if namespace?(value)
          return id.token.to_s == value.to_s if id.respond_to?(:token)
          if id.respond_to?(:identifier)
            name = value.split('::').last
            return id.identifier.token == name
          end
        end
      else
        has_const?(value)
      end
    end

    def has_value?(value)
      self.value == value if respond_to?(:value)
    end

    def position?(pos)
      position == pos
    end

    def left_of?(right)
      right.nil? || self.position < right.position
    end

    def right_of?(left)
      left.nil? || left.position < self.position
    end

    protected

    def namespace?(full_name)
      if full_name.split('::').size > 1
        namespaces = full_name.split('::')[0..-2]
        namespace = namespaces.join('::')

        if class_or_module?
          return module_namespace?(namespace)
        end
      end
      true
    end

    def class_or_module?
      [Ruby::Class, Ruby::Module].include?(self.class)
    end

    def module_namespace?(namespace)
      namespace == get_full_namespace(get_namespace) 
    end

    def get_namespace
      return self.const.namespace if self.respond_to?(:const)
      self.identifier.namespace      
    end

    def get_full_namespace(ns)
      if ns.respond_to?(:namespace)
        name = ns.identifier.token 
        parent_ns = get_full_namespace(ns.namespace)
        name += ('::' + parent_ns) if !parent_ns.empty?
        return name.split('::').reverse.join('::')
      else
        return ns.identifier.token if ns.respond_to?(:identifier)
        ""
      end
    end


  end
end
end
