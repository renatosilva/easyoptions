#!/usr/bin/env ruby
# Encoding: UTF-8

## EasyOptions Example
## Copyright (C) Someone
## Licensed under XYZ
##
## This program is an example of EasyOptions. It just prints the options and
## arguments provided in command line. Usage:
##
##     @script.name [option] ARGUMENTS...
##
## Options:
##     -h, --help              All client scripts have this, it can be omitted.
##     -o, --some-option       This is a boolean option. Long version is
##                             mandatory, and can be specified before or
##                             after short version.
##         --some-boolean      This is a boolean option without a short version.
##         --some-value=VALUE  This is a parameter option. When calling your script
##                             the equal sign is optional and blank space can be
##                             used instead. Short version is not available in this
##                             format.

require_relative 'easyoptions'
options, arguments = EasyOptions.all

# Boolean options
puts 'Option specified: --some-option'  if options[:some_option]
puts 'Option specified: --some-boolean' if options[:some_boolean]

# Parameter option
value = options[:some_value]
if value
    type = value.is_a?(Fixnum) ? 'number' : 'string'
    puts "Option specified: --some-value is #{value} (a #{type})"
end

# Arguments
arguments.each do |argument|
    puts "Argument specified: #{argument}"
end
