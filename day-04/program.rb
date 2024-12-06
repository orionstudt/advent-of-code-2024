def get_mode()
  arguments = ARGV
  return 'example' if arguments.empty?
  mode = arguments[0]
  return mode if ['example','input'].include? mode
  raise ArgumentError, "Invalid Mode: #{mode}"
end

TARGET = "XMAS"

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
        next if character != TARGET[0]
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
    return 0 unless @grid.is_match?(TARGET[0], @x, @y)

    left = 1
    right = 1

    top = 1
    bottom = 1

    top_left = 1
    top_right = 1

    bottom_left = 1
    bottom_right = 1

    for i in (1..TARGET.length - 1)
      character = TARGET[i]

      # horizontal
      left = 0 unless @grid.is_match?(character, @x - i, @y)
      right = 0 unless @grid.is_match?(character, @x + i, @y)

      # vertical
      top = 0 unless @grid.is_match?(character, @x, @y + i)
      bottom = 0 unless @grid.is_match?(character, @x, @y - i)

      # top diagonal
      top_left = 0 unless @grid.is_match?(character, @x - i, @y + i)
      top_right = 0 unless @grid.is_match?(character, @x + i, @y + i)

      # bottom diagonal
      bottom_left = 0 unless @grid.is_match?(character, @x - i, @y - i)
      bottom_right = 0 unless @grid.is_match?(character, @x + i, @y - i)
    end

    left + right + top + bottom + top_left + top_right + bottom_left + bottom_right
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
