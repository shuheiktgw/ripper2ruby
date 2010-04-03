require File.dirname(__FILE__) + '/test_helper'

class TraversalTest < Test::Unit::TestCase
  include TestHelper
  
  # define_method :"test select by token" do
  #   nodes = build('1 + (1 + (1 + 2))').select(:token => '1')
  #   assert_equal 3, nodes.size
  #   assert_equal [Ruby::Integer], nodes.map(&:class).uniq
  #   assert_equal ['1', '1', '1'], nodes.map(&:token)
  # end
  # 
  # define_method :"test select by value" do
  #   nodes = build('1 + (1 + (1 + 2))').select(:value => 2)
  #   assert_equal 1, nodes.size
  #   assert_equal [Ruby::Integer], nodes.map(&:class).uniq
  #   assert_equal ['2'], nodes.map(&:token)
  # end
  # 
  # define_method :"test select by position" do
  #   nodes = build('1 + (2 + (3 + 4))').select(:position => [0, 10])
  #   assert_equal 3, nodes.size
  #   assert_equal [Ruby::Statements, Ruby::Binary, Ruby::Integer], nodes.map(&:class)
  #   assert_equal '3', nodes.last.token
  #   assert_equal [0, 10], nodes.last.position.to_a
  # end
  # 
  # define_method :"test select by a single klass" do
  #   nodes = build('1 + (2 + (3 + 4))').select(Ruby::Operator)
  #   assert_equal 3, nodes.size
  #   assert_equal [Ruby::Binary], nodes.map(&:class).uniq
  #   assert_equal '+', nodes.last.operator.token
  #   assert_equal [0, 10], nodes.last.position.to_a
  # end
  # 
  # define_method :"test select by :left_of" do
  #   nodes = build('1 + (2 + (3 + 4))')
  #   right = nodes.select(Ruby::Integer, :value => 3).first
  #   nodes = nodes.select(Ruby::Integer, :left_of => right)
  #   assert_equal 2, nodes.size
  #   assert_equal [Ruby::Integer], nodes.map(&:class).uniq
  #   assert_equal ['1', '2'], nodes.map(&:token)
  # end
  # 
  # define_method :"test select by :right_of" do
  #   nodes = build('1 + (2 + (3 + 4))')
  #   right = nodes.select(Ruby::Integer, :value => 3).first
  #   nodes = nodes.select(Ruby::Integer, :right_of => right)
  #   assert_equal 1, nodes.size
  #   assert_equal [Ruby::Integer], nodes.map(&:class).uniq
  #   assert_equal ['4'], nodes.map(&:token)
  # end  
  
  define_method :"test select expression block within a Module" do    
    
    # require File.dirname(__FILE__) + '/ruby_api'
                   
    src = "I18n.t(:foo)"
    code = Ripper::RubyBuilder.build(src)
    code.to_ruby # => "I18n.t(:foo)"

    foo = code.select(Ruby::Symbol).first
    foo.identifier.token = 'bar'
    code.to_ruby # => "I18n.t(:bar)"
    


    src = %q{      
      module Xyz::Xxx::Blip
        2
      end    

      class Abc::Bef::Monty 
      end 
    }


    
    code = Ripper::RubyBuilder.build(src)      
    # puts code.inspect
    # mod = code.select(Ruby::Module).first     
    # puts "Prolog:"           
    # puts mod.const.identifier.inspect
    # puts "Namespace:"               
    # puts mod.const.namespace.inspect
    # puts mod.const.identifier.prolog.elements.inspect
    
    module_node = code.find_module('Xyz::Xxx::Blip') 
    puts "module: #{module_node}" 

    # puts "Statements: #{n.identifier.identifier.token.inspect}"

#    puts "Statements: #{n.body[1].parent.identifier.identifier.token.inspect}"
    # .identifier.inspect
    # puts n.inspect

   clazz_node = code.find_class('Abc::Bef::Monty') 
   puts "class: #{clazz_node}" 
    # hello_module.const.identifier.token = 'Blip'
    # puts nodes.to_ruby    
    
    # can't seem to select internal expression from here!?
  end

  # TODO: externalize in DSL API on top of primitive API, see Ruby Best Practices!

    
  
end