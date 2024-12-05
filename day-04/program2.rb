def get_mode()
  arguments = ARGV
  return 'example' if arguments.empty?
  mode = arguments[0]
  return mode if ['example','example2','input'].include? mode
  raise ArgumentError, "Invalid Mode: #{mode}"
end

# grid is like
#   Y
# X 0 1 2 3 4
#   1
#   2
#   3
#   4
class Grid
  attr_reader :rows

  def initialize(rows)
    @rows = rows
  end

  def get_possibilities
    result = []

    for y in (0..rows.size - 1)
      row = rows[y]
      for x in (0..row.length - 1)
        character = row[x]
        next if character != "A"
        result.push(Possibility.new(self, x, y))
      end
    end

    result
  end

  def is_match?(character, x, y)
    return false if x.negative? || y.negative?

    # y is first because it's an array of rows
    row = rows[y]
    return false if row.nil? || x > row.length - 1
    return row[x] == character
  end
end

class Possibility
  def initialize(grid, x, y)
    @grid = grid
    @x = x
    @y = y
  end

  def match_count
    return 0 unless @grid.is_match?("A", @x, @y)
    return 1 if TL_BR_match? && BL_TR_match?
    return 0
  end

  private

  # top left to bottom right match
  def TL_BR_match?
    mas = @grid.is_match?("M", @x - 1, @y + 1) && @grid.is_match?("S", @x + 1, @y - 1)
    sam = @grid.is_match?("S", @x - 1, @y + 1) && @grid.is_match?("M", @x + 1, @y - 1)
    return mas || sam
  end

  # bottom left to top right match
  def BL_TR_match?
    mas = @grid.is_match?("M", @x - 1, @y - 1) && @grid.is_match?("S", @x + 1, @y + 1)
    sam = @grid.is_match?("S", @x - 1, @y - 1) && @grid.is_match?("M", @x + 1, @y + 1)
    return mas || sam
  end
end

def get_inputs(mode)
  rows = File.open("./day-04/#{mode}.txt").read.strip.split("\n")
  Grid.new(rows)
end

def execute(mode)
  grid = get_inputs mode
  puts "Grid Rows = #{grid.rows.size}"
  
  sum = 0
  for possibility in grid.get_possibilities do
    sum += possibility.match_count
  end

  puts "Total Matches = #{sum}"
end

mode = get_mode
execute(mode)
