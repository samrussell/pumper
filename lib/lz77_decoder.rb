class Lz77Decoder
  def decode(encoded_chars)
    decoded_chars = []

    encoded_chars.each do |literal_or_copy|
      if literal_or_copy.is_a?(String)
        decoded_chars.push(literal_or_copy)
      else
        distance, length = literal_or_copy
        length.times.each do
          decoded_chars.push(decoded_chars[-distance])
        end
      end
    end

    decoded_chars
  end
end