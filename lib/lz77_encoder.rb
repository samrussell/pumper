class Lz77Encoder
  attr_reader :matches

  def encode(decoded_data)
    encoded_data = []
    @matches = {}
    # encode looking 2 bytes ahead
    index = 0
    while index < (decoded_data.length-2)
      key = decoded_data[index...index+3]
      if matches.key?(key)
        # find the longest match
        lengths = matches[key].map do |offset|
          match_length = 0

          while decoded_data[index+match_length] == decoded_data[offset+match_length]
            match_length += 1
          end

          match_length
        end

        match_length = lengths.max
        longest_match_location = lengths.rindex(match_length)
        match_index = matches[key][longest_match_location]
        distance = index-match_index

        encoded_data.push([distance, match_length])

        # add all the next bits to the dictionary before we skip over them
        (0...match_length).each do |offset|
          key = decoded_data[index+offset...index+offset+3]

          if not matches.key?(key)
            matches[key] = []
          end

          matches[key].push(index+offset)
        end

        index += match_length
      else
        matches[key] = []
        encoded_data.push(decoded_data[index])
        matches[key].push(index)
        index += 1
      end
    end

    if index == decoded_data.length-2
      encoded_data += decoded_data[-2..-1]
    elsif index == decoded_data.length-1
      encoded_data.push(decoded_data[-1])
    end

    encoded_data
  end
end