module RubyAPI
  def find_module(name)
    select(Ruby::Module, :identifier => name).first
  end

  def find_class(name, options = {})
    options.merge!(:identifier => name)
    select(Ruby::Class, options).first    
  end

  def find_block(name, options = {})
    options.merge!(:identifier => name)
    select(options).first    
  end 


end

module Ruby
  class Node
    include RubyAPI
  end
end