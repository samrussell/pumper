require "./lib/lz77_decoder.rb"
require "./lib/lz77_encoder.rb"

describe "LZ77 encoder/decoders" do 
  let(:decoded_data) do
    ("Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed " +
    "do eiusmod tempor incididunt ut labore et dolore magna aliqua. " +
    "Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris " +
    "nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in " +
    "reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla " +
    "pariatur. Excepteur sint occaecat cupidatat non proident, sunt in " +
    "culpa qui officia deserunt mollit anim id est laborum.\n").chars
  end

  let(:encoder) { Lz77Encoder.new }
  let(:decoder) { Lz77Decoder.new }

  it "encodes to something smaller and then decodes correctly" do
    encoded_data = encoder.encode(decoded_data)
    actual_decoded_data = decoder.decode(encoded_data)

    expect(encoded_data.length).to be < decoded_data.length
    expect(decoded_data).to eq(actual_decoded_data)
  end
end