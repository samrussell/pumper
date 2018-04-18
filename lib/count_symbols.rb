class CountSymbols
  def initialize(decoded_data)
    @decoded_data = decoded_data
  end

  def counts
    counts = Hash.new(0)
    highest_char = 0

    @decoded_data.each do |char|
      counts[char.ord] += 1
      highest_char = [highest_char, char.ord].max
    end

    (highest_char+1).times.map { |index| counts[index] }
  end
end