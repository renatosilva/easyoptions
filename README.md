# EasyOptions

EasyOptions allows you to write the help text for your program *only once*, and have the described options *automatically parsed* from command line into easily readable variables, *without complicated API*. EasyOptions was development after discontentment with the existing solutions for option parsing in Bash and Ruby. It was conceived with the following guidelines in mind:

  * Avoid duplication of source code documentation, help text and options specification.
  * Have the option values parsed into easily readable variables.
  * Have the non-option arguments available on a simple, separate array.
  * Usage as simple as one single line of code.

EasyOptions is going to parse all of your options and arguments automatically once sourced. You specify what options are supported by your program by simply writing a help text, using special double-hash comments. This help text also works at the same time as source code documentation and options specification. All client scripts have an automatic `--help` option, which is going to display such documentation. You can see more details, specially about the options specification, in the help text of EasyOptions itself.

## Usage

For using EasyOptions in your script, simply document it using double-hash comments like this:

```
## Program Name v1.0
## Copyright (C) Someone
## Licensed under XYZ
##
## This program does something with the arguments. Usage:
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
```

The above comments work both as source code documentation and as help text, as well as define the options supported by your script. There is no duplication of the options specification. The string `@script.name` will be replaced with the actual script name. Now you only need to call EasyOptions in your script and *that's it*!

### Ruby version

After writing your documentation, you simply require this script. Then all command line options will get parsed into the `$options` hash, as described above. You can then check their values for reacting to them. All regular arguments will get stored into the `$arguments` array. Here is an example for parsing the comments above:

```ruby
require_relative "easyoptions"

# Boolean options
puts "Option specified: --some-option"   if $options[:some_option]
puts "Option specified: --some-boolean"  if $options[:some_boolean]

# Parameter option
value = $options[:some_value]
if value
    type = value.is_a?(Fixnum)? "number" : "string"
    puts "Option specified: --some-value is #{value} (a #{type})"
end

# Arguments
exit if $arguments.empty?
$arguments.each do |argument|
    puts "Argument specified: #{argument}"
end
```

### Bash version

After writing your documentation, you simply source this script. Then all command line options will get parsed into the corresponding variables. You can then check their values for reacting to them. Regular arguments will be available in the `$arguments` array. Here is an example for parsing the comments above:

```bash
source easyoptions "$@" || exit

# Boolean and parameter options
[[ -n "$some_option"  ]] && echo "Option specified: --some-option"
[[ -n "$some_boolean" ]] && echo "Option specified: --some-boolean"
[[ -n "$some_value"   ]] && echo "Option specified: --some-value is $some_value"

# Arguments
for argument in "${arguments[@]}"; do
    echo "Argument specified: $argument"
done
```

For better speed, you may want to define the options in source code yourself, so they do not need to be parsed from the documentation. The side effect is that when changing them, you will need to update both the documentation and the source code. You define the options statically like this:

```bash
options=(o=option some-boolean some-value=?)
```

### Ruby version in Bash

The Ruby version can be used from Bash scripts as well since it is faster. If the `$from` environment variable is set, that will be assumed as the source Bash script from which to parse the documentation and the provided options. Then, instead of parsing the options into Ruby variables, evaluable export statements will be generated for corresponding Bash environment variables. Instead of sourcing the Bash script we call the Ruby version, for example:

```bash
eval "$(from="$0" easyoptions.rb "$@" || echo exit 1)"
```

If the script containing this command is documented as in the example above, and it is executed from command line with the `-o` and `--some-value=10` options, and one regular argument `foo`, then the evaluable output would look like this:

```bash
export some_option="yes"
export some_value="10"
unset arguments
arguments+=("foo")
export arguments
```

## Contributing

The principle behind EasyOptions can be applied in other scripting languages and possibly static ones. If you would like to contribute, a Python port would be very welcome, as well as Java or C versions. Unit tests are also welcome. Or you can just improve the existing code with your ideas and bug fixes and help making option parsing suck a bit less!

## License and copyright

Copyright (c) 2014 Renato Silva.
Licensed under the terms of the GNU GPL version 2.


