def get_mode()
  arguments = ARGV
  return 'example' if arguments.empty?
  mode = arguments[0]
  return mode if ['example','input','test'].include? mode
  raise ArgumentError, "Invalid Mode: #{mode}"
end

class Rule
  attr_reader :key

  def initialize(key)
    @key = key
    @rules = {}
  end

  def should_be_after(page)
    @rules[page] = :after
  end

  def must_be_after?(page)
    rule = @rules[page]
    return false if rule.nil?
    rule == :after
  end

  def should_be_before(page)
    @rules[page] = :before
  end

  def must_be_before?(page)
    rule = @rules[page]
    return false if rule.nil?
    rule == :before
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
  LOG_NOISY = false
  RE_STACK = true

  def initialize(ruleset, updates)
    @ruleset = ruleset
    @updates = updates
  end

  def corrected_updates
    invalid = []

    # iterate each update to find invalid
    for update in @updates do

      # validate each page in the update
      for index in (0..update.size - 1) do
        page = update[index]
        rule = @ruleset[page]
        next if rule.nil?

        before = index == 0 ? [] : update[0..index - 1]
        after = index == update.size - 1 ? [] : update[index + 1..update.size]
        next if rule.is_valid?(before, after)

        invalid.push(update)
        break
      end
    end

    # correct each invalid update
    corrected = []
    for update in invalid do

      puts "Correcting Update: #{update.join(",")}" if LOG_NOISY

      new_version = [update[0]]
      remaining = update.slice(1, update.size)

      while (remaining.size > 0) do
        current = remaining.shift
        puts "Assessing Page: #{current}" if LOG_NOISY

        next if try_add_from_left?(new_version, current)
        puts "Try Left = false" if LOG_NOISY
        next if try_add_from_right?(new_version, current)
        puts "Try Right = false" if LOG_NOISY

        remaining.push(current) if RE_STACK
      end

      corrected.push(new_version)
    end

    corrected
  end

  private

  def try_add_from_left?(update, page)
    # from left to right, looking for a rule that says
    # "compare" should be after "page"
    for index in (0..update.size - 1) do
      puts "From Left Index: #{index}" if LOG_NOISY
      compare = update[index]
      first = @ruleset[compare]
      second = @ruleset[page]

      puts "Page [#{compare}] must be before [#{page}]" if (!first.nil? && first.must_be_before?(page)) && LOG_NOISY
      puts "Page [#{compare}] must be after [#{page}]" if (!first.nil? && first.must_be_after?(page)) && LOG_NOISY
      puts "Page [#{page}] must be before [#{compare}]" if (!second.nil? && second.must_be_before?(page)) && LOG_NOISY
      puts "Page [#{page}] must be after [#{compare}]" if (!second.nil? && second.must_be_after?(page)) && LOG_NOISY
      next unless (!first.nil? && first.must_be_after?(page)) || (!second.nil? && second.must_be_before?(compare))

      puts "Placing Page [#{page}] left of [#{compare}]" if LOG_NOISY
      update.insert(index, page)
      puts "New State: #{update.join(",")}" if LOG_NOISY
      return true
    end

    false
  end

  def try_add_from_right?(update, page)
    # from right to left, looking for a rule that says
    # "compare" should be before "page"
    for index in (update.size - 1).downto(0) do
      puts "From Right Index: #{index}" if LOG_NOISY
      compare = update[index]
      first = @ruleset[compare]
      second = @ruleset[page]

      puts "Page [#{compare}] must be before [#{page}]" if (!first.nil? && first.must_be_before?(page)) && LOG_NOISY
      puts "Page [#{compare}] must be after [#{page}]" if (!first.nil? && first.must_be_after?(page)) && LOG_NOISY
      puts "Page [#{page}] must be before [#{compare}]" if (!second.nil? && second.must_be_before?(page)) && LOG_NOISY
      puts "Page [#{page}] must be after [#{compare}]" if (!second.nil? && second.must_be_after?(page)) && LOG_NOISY
      next unless (!first.nil? && first.must_be_before?(page)) || (!second.nil? && second.must_be_after?(compare))

      puts "Placing Page [#{page}] right of [#{compare}]" if LOG_NOISY
      update.insert(index + 1, page)
      puts "New State: #{update.join(",")}" if LOG_NOISY
      return true
    end

    false
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
    first_rule = ruleset[first].nil? ? Rule.new(first) : ruleset[first]
    first_rule.should_be_before(second)
    ruleset[first] = first_rule

    # define rule for second segment
    second_rule = ruleset[second].nil? ? Rule.new(second) : ruleset[second]
    second_rule.should_be_after(first)
    ruleset[second] = second_rule
  end

  # parse updates
  rows = sections[1].strip.split("\n")
  updates = rows.map { |x| x.split(",") }

  # return print command
  PrintCommand.new(ruleset, updates)
end

def execute(mode)
  command = get_inputs mode
  corrected_updates = command.corrected_updates
  puts "Corrected Updates = #{corrected_updates.size}"
  
  sum = 0
  for update in corrected_updates do
    middle_index = update.size / 2
    middle = update[middle_index].to_i
    puts "Corrected Update: [#{update.join(",")}], Middle: #{middle}"
    sum += middle
  end

  puts "Middle Page Sum = #{sum}"
end

mode = get_mode
execute(mode)
