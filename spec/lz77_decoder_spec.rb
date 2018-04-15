require "./lib/lz77_decoder.rb"

describe Lz77Decoder do
  describe "#decode" do
    let(:decoder) { Lz77Decoder.new(encoded_string) }
    let(:subject) { decoder.decode.to_a }

    context "with just literals" do
      let(:encoded_string) { "abc123!@#".chars }
      let(:decoded_string) { "abc123!@#".chars }
      it { is_expected.to eq(decoded_string) }
    end
    
    context "with simple look-backs (no overrunning)" do
      let(:encoded_string) { "abc123!@#".chars + [[5, 2]] }
      let(:decoded_string) { "abc123!@#23".chars }
      it { is_expected.to eq(decoded_string) }
    end
    
    context "with more complex look-backs (no overrunning)" do
      let(:encoded_string) { "abc123!@#".chars + [[5, 2], [7, 2], [10, 3]] }
      let(:decoded_string) { "abc123!@#2323123".chars }
      it { is_expected.to eq(decoded_string) }
    end
    
    context "with complex look-backs (overrunning)" do
      let(:encoded_string) { "abc123!@#".chars + [[5, 2], [7, 2], [10, 3], [5, 30]] }
      let(:decoded_string) { "abc123!@#2323123231232312323123231232312323123".chars }
      it { is_expected.to eq(decoded_string) }
    end
  end
end