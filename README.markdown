Ripper2Ruby
===========

Similar to ruby2ruby this library allows to parse Ruby code, modify and 
recompile it back to Ruby.

Differences:

* uses Ripper for parsing (shipped with Ruby 1.9)
* produces a full object-oriented representation of the Ruby code

Higher level select API
=======================

* A higher level API is to facilitate selecting parts of the parse tree   

See files: ruby_api.rb and ruby_api_traversal_test.rb

Find module
------------

# module Monty::Python ... end
code.find_module('Monty::Python') 

Find class
----------

# class Monty::Python ... end
code.find_class('Monty::Python') 

# class Monty < Abc::Blip ... end
code.find_class('Monty', :superclass => 'Abc::Blip') 

Find block
----------

# my_block do ... end
code.find_block('my_block') 

# my_block do |v| ... end
code.find_block('my_block', :block_params => ['v']) 

# my_block 7, 'a' do ... end
code.find_block('my_block', :args => [7, 'a']) 

# my_block 7, 'a', :k => 32 do |v| ... end
code.find_block('my_block', :args => [7, 'a', {:k => 32}], :block_params => ['v']) 


More to come...