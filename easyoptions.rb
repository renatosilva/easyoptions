#!/usr/bin/env ruby
# Encoding: ISO-8859-1

##
##     EasyOptions 2014.7.23
##     Copyright (c) 2013, 2014 Renato Silva
##     GNU GPLv2 licensed
##
## This script is supposed to parse command line arguments in a way that,
## even though its implementation is not trivial, it should be easy and
## smooth to use. For using this script, simply document your target script
## using double-hash comments, like this:
##
##     ## Program Name v1.0
##     ## Copyright (C) Someone
##     ##
##     ## This program does something. Usage:
##     ##     @#script.name [option]
##     ##
##     ## Options:
##     ##     -h, --help              All client scripts have this by default,
##     ##                             it shows this double-hash documentation.
##     ##
##     ##     -o, --option            This option will get stored as true value
##     ##                             under $options[:option]. Long version is
##     ##                             mandatory, and can be specified before or
##     ##                             after short version.
##     ##
##     ##         --some-boolean      This will get stored as true value under
##     ##                             $options[:some_boolean].
##     ##
##     ##         --some-value=VALUE  This is going to store the VALUE specified
##     ##                             under $options[:some_value]. The equal
##     ##                             sign is optional and can be replaced with
##     ##                             blank space when running the target
##     ##                             script. If VALUE is composed of digits, it
##     ##                             will be converted into an integer,
##     ##                             otherwise it will get stored as a string.
##     ##                             Short version is not available in this
##     ##                             format.
##
## The above comments work both as source code documentation and as help
## text, as well as define the options supported by your script. There is no
## duplication of the options specification. The string @#script.name will be
## replaced with the actual script name.
##
## After writing your documentation, you simply require this script. Then all
## command line options will get parsed into the $options hash, as described
## above. You can then check their values for reacting to them. All regular
## arguments will get stored into the $arguments array.
##
## In fact, this script is an example of itself. You are seeing this help
## message either because you are reading the source code, or you have called
## the script in command line with the --help option.
##
## This script can be used from Bash scripts as well. If the $from environment
## variable is set, that will be assumed as the source Bash script from which to
## parse the documentation and the provided options. Then, instead of parsing
## the options into Ruby variables, evaluable export statements will be
## generated for corresponding Bash environment variables. For example:
##
##     eval "$(from="$0" @script.name "$@" || echo exit 1)"
##
## If the script containing this command is documented as in the example above,
## and it is executed from command line with the -o and --some-value=10 options,
## and one regular argument abc, then the evaluable output would look like this:
##
##     export option="yes"
##     export some_value="10"
##     unset arguments
##     arguments+=("abc")
##     export arguments
##

class Option
    def initialize(long_version, short_version, boolean=true)
        raise ArgumentError.new("Long version is mandatory") if not long_version or long_version.length < 2
        @short = short_version.to_sym if short_version
        @long = long_version.to_s.gsub("-", "_").to_sym
        @boolean = boolean
    end
    def to_s
        "--#{long_dashed}"
    end
    def in?(string)
        string =~ /^--#{long_dashed}$/ or (@short and string =~ /^-#{@short}$/)
    end
    def in_with_value?(string)
        string =~ /^--#{long_dashed}=.*$/
    end
    def long_dashed
        @long.to_s.gsub("_", "-")
    end
    attr_accessor :short
    attr_accessor :long
    attr_accessor :boolean
end

def finish(error)
    $stderr.puts "Error: #{error}."
    $stderr.puts "See --help for usage and options."
    puts "exit 1" if BashOutput
    exit false
end

def parse_doc
    begin
        doc = File.readlines($0)
    rescue Errno::ENOENT
        exit false
    end
    doc = doc.find_all do |line|
        line =~ /^##[^#]*/
    end
    doc = doc.map do |line|
        line.strip!
        line.sub!(/^## ?/, "")
        line.gsub!(/@script.name/, File.basename($0))
        line.gsub(/@#/, "@")
    end
end

def check_bash_output
    $0 = ENV["from"] || $0
    $0 == ENV["from"]
end

# Initialization
known_options = [ Option.new(:help, :h)]
BashOutput = check_bash_output
$documentation = parse_doc
$arguments = []
$options = {}

# Parse known options from documentation
$documentation.map do |line|
    line = line.strip
    case line
        when /^-h, --help.*/ then next
        when /^--help, -h.*/ then next
        when /^-.*, --.*/    then line = line.split(/(^-|,\s--|\s)/);  known_options << Option.new(line[4], line[2])
        when /^--.*, -.*/    then line = line.split(/(--|,\s-|\s)/);   known_options << Option.new(line[2], line[4])
        when /^--.*=.*/      then line = line.split(/(--|=|\s)/);      known_options << Option.new(line[2], nil, false)
        when /^--.* .*/      then line = line.split(/(--|\s)/);        known_options << Option.new(line[2], nil)
    end
end

# Format arguments input
arguments = ARGV.map do |argument|
    if argument =~ /^-[^-].*$/i then
        argument.split("")[1..-1].map { |char| "-#{char}" }
    else
        argument
    end
end.flatten

# Parse the provided options
arguments.each_with_index do |argument, index|
    unknown_option = true
    known_options.each do |known_option|

        # Boolean option
        if known_option.in?(argument) and known_option.boolean then
            $options[known_option.long] = true
            unknown_option = false
            break

        # Option with value in next parameter
        elsif known_option.in?(argument) and not known_option.boolean then
            value = arguments[index + 1]
            finish("you must specify a value for #{known_option}") if not value
            value = value.to_i if value =~ /^[0-9]+$/
            $options[known_option.long] = value
            unknown_option = false
            break

        # Option with value after equal sign
        elsif known_option.in_with_value?(argument) and not known_option.boolean then
            value = argument.split("=")[1]
            value = value.to_i if value =~ /^[0-9]+$/
            $options[known_option.long] = value
            unknown_option = false
            break

        # Long option with unnecessary value
        elsif known_option.in_with_value?(argument) and known_option.boolean then
            value = argument.split("=")[1]
            finish("#{known_option} does not accept a value (you specified `#{value}')")
        end
    end

    # Unrecognized option
    finish("unrecognized option `#{argument}'") if unknown_option and argument.start_with?("-")
end

# Help option
if $options[:help]
    if BashOutput then
        print "printf '"
        puts $documentation
        puts "'"
        puts "exit"
    else
        puts $documentation
    end
    exit -1
end

# Regular arguments
next_is_value = false
arguments.each do |argument|
    if argument.start_with?("-") then
        known_option = known_options.find { |known_option| known_option.in?(argument) }
        next_is_value = (known_option and not known_option.boolean)
    else
        $arguments << argument if not next_is_value
        next_is_value = false
    end
end

# Bash support
if BashOutput then
    $options.keys.each do |name|
        puts "export #{name}=\"#{$options[name].to_s.sub("true", "yes")}\""
    end
    puts "unset arguments"
    $arguments.each do |argument|
        puts "arguments+=(\"#{argument}\")"
    end
    puts "export arguments"
end
