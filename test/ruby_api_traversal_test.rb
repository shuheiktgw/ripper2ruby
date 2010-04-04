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

  define_method :"test select block" do                           
    src = %q{ 
      my_block = 7     
      my_block do
        1
      end 
    }
    code = Ripper::RubyBuilder.build(src)              
    block_node = code.find_block('my_block')  
    assert_equal Ruby::Call, block_node.class
  end

  define_method :"test select block with args" do                           
    # my_block 7, :abe => true do |v|    
    # 7, 'a', :blip,     
    src = %q{  

      my_block :hello => 7 do
        1
      end 
    }
    code = Ripper::RubyBuilder.build(src)               
    # , {'abe' => true}                                  
    # , :params => ['v']                                   
    # 7, 'a', :blip, 
    block_node = code.find_block('my_block', :args => [{:hello => 7}]) 
    assert_equal Ruby::Call, block_node.class
    # puts block_node.inspect 
    # puts "arg: " + block_node.arguments.elements[0].arg.elements[0].key.identifier.token  
    # puts "param: " + block_node.block.params.elements[0].param.token
  end

  define_method :"test select block with params" do                           
    # my_block 7, :abe => true do |v|    
    # 7, 'a', :blip,     
    src = %q{  

      my_block do |v|
        1
      end 
    }
    code = Ripper::RubyBuilder.build(src)               
    # , {'abe' => true}                                  
    # ,                                    
    # 7, 'a', :blip, 
    block_node = code.find_block('my_block', :block_params => ['v']) 
    assert_equal Ruby::Call, block_node.class
    # puts block_node.inspect 
    # puts "arg: " + block_node.arguments.elements[0].arg.elements[0].key.identifier.token  
    # puts "param: " + block_node.block.params.elements[0].param.token
  end



  
end