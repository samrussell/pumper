class Lz77Decoder
  def initialize(encoded_chars)
    @encoded_chars = encoded_chars
    @decoded_chars = []
  end

  def decode(&block)
    return enum_for(:decode) unless block_given?

    @encoded_chars.each do |literal_or_copy|
      if literal_or_copy.is_a?(String)
        yield_and_store(literal_or_copy, &block)
      else
        distance, length = literal_or_copy
        length.times.each do
          yield_and_store(@decoded_chars[-distance], &block)
        end
      end
    end
  end

  private

  def yield_and_store(char)
    @decoded_chars.push(char)
    yield char
  end
end