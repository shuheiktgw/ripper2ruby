module RubyAPI
  def find_module(name)
    select(Ruby::Module, :identifier => name).first
  end

  def find_class(name)
    select(Ruby::Class, :identifier => name).first    
  end
end

module Ruby
  class Node
    include RubyAPI
  end
end