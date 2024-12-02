require 'pry';

def get_mode()
  arguments = ARGV
  return 'example' if arguments.empty?
  mode = arguments[0]
  return mode if ['example','input','test'].include? mode
  raise ArgumentError, "Invalid Mode: #{mode}"
end

def get_inputs(mode)
  rows = File.open("./day-02/#{mode}.txt").read.strip.split("\n")
  reports = []

  for row in rows do
    levels = row.strip.split(" ").map(&:to_i)
    reports.push(levels)
  end

  reports
end

def check_safety(report, run_dampener = true)
  minimum_diff = 1
  maximum_diff = 3
  level_mode = report.first > report[1] ? :decreasing : :increasing
  
  safety = true
  for index in (0..report.size - 1) do
    level = report[index]
    behind = index >= 1 ? report[index - 1] : nil
    ahead = index <= report.size - 2 ? report[index + 1] : nil
    
    if (behind != nil)
      # check increasing/decreasing
      case level_mode
      when :increasing
        safety = false if behind >= level
      when :decreasing
        safety = false if behind <= level
      end

      # check behind difference
      diff = (behind - level).abs
      safety = false if diff < minimum_diff || diff > maximum_diff
    end

    # check ahead difference
    if (ahead != nil)
      diff = (ahead - level).abs
      safety = false if diff < minimum_diff || diff > maximum_diff
    end

    # break on unsafe
    break if !safety
  end

  return true if safety

  # check and run dampener for each index
  if (run_dampener)
    for index in (0..report.size - 1) do
      reduced_report = report.clone
      reduced_report.delete_at index
      safety = check_safety(reduced_report, run_dampener = false)
      return true if safety
    end
  end
  

  false
end

def execute(mode)
  reports = get_inputs mode
  puts "Reports Length = #{reports.size}"

  safe_counter = 0
  for report in reports do
    # check safety
    result = check_safety(report)
    safe_counter = safe_counter + 1 if result

    # build string
    report_str = report.join(" ")
    result_str = result ? "Safe" : "Unsafe"
    puts "Report #{report_str} = #{result_str}"
  end

  puts "Reports Safe = #{safe_counter}"
end

mode = get_mode
execute(mode)
