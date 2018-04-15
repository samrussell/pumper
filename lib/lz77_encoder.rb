class MatchDictionary
  attr_reader :match_index
  attr_reader :match_length

  def initialize(decoded_data)
    @decoded_data = decoded_data
    @matches = {}
  end

  def add(index)
    key = @decoded_data[index...index+3]

    @matches[key] = [] unless @matches.key?(key)

    @matches[key].push(index)
  end

  def longest_match_and_length(index)
    key = @decoded_data[index...index+3]

    return unless @matches.key?(key)

    # find the longest match
    lengths = @matches[key].map do |offset|
      match_length = 0

      while @decoded_data[index+match_length] == @decoded_data[offset+match_length]
        match_length += 1
      end

      match_length
    end

    @match_length = lengths.max
    longest_match_location = lengths.rindex(@match_length)
    @match_index = @matches[key][longest_match_location]

    [@match_index, @match_length]
  end
end

class Lz77Encoder
  def initialize(decoded_data)
    @decoded_data = decoded_data
  end

  def encode
    return enum_for(:encode) unless block_given?

    match_dictionary = MatchDictionary.new(@decoded_data)

    # encode looking 2 bytes ahead
    index = 0

    while index < (@decoded_data.length-2)
      if match_dictionary.longest_match_and_length(index)
        distance = index-match_dictionary.match_index

        yield [distance, match_dictionary.match_length]

        # add all the next bits to the dictionary before we skip over them
        (0...match_dictionary.match_length).each do |offset|
          key = @decoded_data[index+offset...index+offset+3]

          match_dictionary.add(index+offset)
        end

        index += match_dictionary.match_length
      else
        match_dictionary.add(index)

        yield @decoded_data[index]

        index += 1
      end
    end

    if index == @decoded_data.length-2
      @decoded_data[-2..-1].each {|data| yield data}
    elsif index == @decoded_data.length-1
      yield @decoded_data[-1]
    end
  end
end