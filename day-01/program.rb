def get_mode()
  arguments = ARGV
  return 'example' if arguments.empty?
  mode = arguments[0]
  return mode if ['example','input'].include? mode
  raise ArgumentError, "Invalid Mode: #{mode}"
end

def get_inputs(mode)
  rows = File.open("./day-01/#{mode}.txt").read.strip.split("\n")
  list1 = []
  list2 = []

  for row in rows do
    items = row.strip.split(" ")
    list1.push(items[0].to_i)
    list2.push(items[1].to_i)
  end

  [list1.sort, list2.sort]
end

def execute(mode)
  inputs = get_inputs mode
  puts "List 1 length = #{inputs.first.size}"
  puts "List 2 length = #{inputs.last.size}"

  puts "Current Distance = 0"
  distance = 0
  similarity = 0
  for i in (0..inputs.first.size - 1) do
    a = inputs.first[i]
    b = inputs.last[i]

    # do distance
    current_distance = (a - b).abs
    puts "Current Distance ##{i} = #{distance} + #{current_distance} (#{a} - #{b})"
    distance = distance + current_distance

    # do similarity
    appearances = inputs.last.select { |x| x == a }.size
    current_similarity = a * appearances
    similarity = similarity + current_similarity
  end
  puts "Total Distance = #{distance}"
  puts "Similarity Score = #{similarity}"
end

mode = get_mode
execute(mode)
