require File.dirname(__FILE__) + '/test_helper'

class TraversalTest < Test::Unit::TestCase
  include TestHelper

  def setup
  end
    
  define_method :"test select Module with complex namespace" do                           
    src = %q{      
      module Xyz::Xxx::Blip
        2
      end    
    }
    
    code = Ripper::RubyBuilder.build(src)          
    module_node = code.find_module('Xyz::Xxx::Blip') 
    assert_equal Ruby::Module, module_node.class 
    # puts "module: #{module_node}" 
  end

  define_method :"test select Class with complex namespace" do                           
    src = %q{      
      class Abc::Bef::Monty 
      end 
    }
    code = Ripper::RubyBuilder.build(src)              
    clazz_node = code.find_class('Abc::Bef::Monty') 
    assert_equal Ruby::Class, clazz_node.class
    # puts "class: #{clazz_node}" 
  end


  define_method :"test select Class that inherits from other Class" do                           
    src = %q{      
      class Monty < Abc::Blip 
      end 
    }
    code = Ripper::RubyBuilder.build(src)              
    clazz_node = code.find_class('Monty', :superclass => 'Abc::Blip') 
    assert_equal Ruby::Class, clazz_node.class     
    # puts "class: #{clazz_node}" 
  end

  
end