def get_mode()
  arguments = ARGV
  return 'example' if arguments.empty?
  mode = arguments[0]
  return mode if ['example','input'].include? mode
  raise ArgumentError, "Invalid Mode: #{mode}"
end

class Rule
  attr_reader :page

  def initialize(page)
    @page = page
    @rules = {}
  end

  def should_be_after(page)
    @rules[page] = :after
  end

  def should_be_before(page)
    @rules[page] = :before
  end

  def is_valid?(before, after)
    # verify that this page is after all pages before it
    for page in before do
      next if @rules[page].nil?
      return false if @rules[page] == :before
    end

    # verify that this page is before all pages after it
    for page in after do
      next if @rules[page].nil?
      return false if @rules[page] == :after
    end

    true
  end
end

class PrintCommand
  def initialize(ruleset, updates)
    @ruleset = ruleset
    @updates = updates
  end

  def valid_updates
    valid = []

    # iterate each update
    for update in @updates do
      is_valid = true

      # validate each page in the update
      for index in (0..update.size - 1) do
        page = update[index]
        rule = @ruleset[page]
        next if rule.nil?

        before = index == 0 ? [] : update[0..index - 1]
        after = index == update.size - 1 ? [] : update[index + 1..update.size]
        next if rule.is_valid?(before, after)

        is_valid = false
        break
      end

      valid.push(update) if is_valid
    end

    valid
  end
end

def get_inputs(mode)
  sections = File.open("./day-05/#{mode}.txt").read.strip.split("\n\n")

  # parse rules
  ruleset = {}
  rows = sections[0].strip.split("\n")
  for row in rows do
    pair = row.split("|")
    first = pair.first
    second = pair.last

    # define rule for first segment
    rule = ruleset[first].nil? ? Rule.new(first) : ruleset[first]
    rule.should_be_before(second)
    ruleset[first] = rule

    # define rule for second segment
    rule = ruleset[second].nil? ? Rule.new(second) : ruleset[second]
    rule.should_be_after(first)
    ruleset[second] = rule
  end

  # parse updates
  rows = sections[1].strip.split("\n")
  updates = rows.map { |x| x.split(",") }

  # return print command
  PrintCommand.new(ruleset, updates)
end

def execute(mode)
  command = get_inputs mode
  valid_updates = command.valid_updates
  puts "Valid Updates = #{valid_updates.size}"
  
  sum = 0
  for update in valid_updates do
    middle_index = update.size / 2
    sum += update[middle_index].to_i
  end

  puts "Middle Page Sum = #{sum}"
end

mode = get_mode
execute(mode)
