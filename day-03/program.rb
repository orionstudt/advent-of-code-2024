def get_mode()
  arguments = ARGV
  return 'example' if arguments.empty?
  mode = arguments[0]
  return mode if ['example','example2','input'].include? mode
  raise ArgumentError, "Invalid Mode: #{mode}"
end

def get_inputs(mode)
  text = File.open("./day-03/#{mode}.txt").read.strip
  regex = /mul\(\d{1,3}\,\d{1,3}\)|don\'t\(\)|do\(\)/
  text.scan(regex)
  matches = text.scan(regex)
end

def parse_mult_command(command)
  command.sub("mul(", "").sub(")", "").split(',').map(&:to_i)
end

def execute(mode)
  commands = get_inputs mode
  puts "Commands Length = #{commands.size}"
  
  sum = 0
  enabled = true
  for command in commands do
    # parse don't
    if (command.start_with? "don't")
      enabled = false
      puts "Command Processing Enabled = #{enabled}"
    # parse do
    elsif (command.start_with? "do(")
      enabled = true
      puts "Command Processing Enabled = #{enabled}"
    # handle mult
    elsif (enabled)
      pair = parse_mult_command(command)
      a = pair[0]
      b = pair[1]
      multiple = a * b
      puts "Sum = #{sum} + #{multiple} (#{a} * #{b})"
      sum += multiple
    end
  end

  puts "Total Sum = #{sum}"
end

mode = get_mode
execute(mode)
