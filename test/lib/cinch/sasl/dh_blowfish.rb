require_relative "../../../test_helper"
require "cinch/sasl/dh_blowfish"

class DhBlowfishTest < TestCase
  test "mechanism_name is correct" do
    assert_equal "DH-BLOWFISH", Cinch::SASL::DhBlowfish.mechanism_name
  end

  test "unpack_payload parses binary data" do
    # Format: 2-byte length + payload, repeated 3 times (p, g, y)
    
    # Create valid payload
    p_val = "23" # prime string dec
    g_val = "5"
    y_val = "10"
    
    # Pack as binary strings
    # But wait, unpack_payload expects payload to be... binary?
    # It does: `size = payload.unpack1("n"); payload.slice!(0, 2); payload.unpack1("a#{size}")`
    # So we construct binary payload.
    
    p_bin = p_val
    g_bin = g_val
    y_bin = y_val
    
    payload = String.new
    [p_bin, g_bin, y_bin].each do |val|
      payload << [val.bytesize].pack("n")
      payload << val
    end
    
    # unpack_payload converts binary string -> OpenSSL::BN -> integer
    # Wait, `OpenSSL::BN.new(i, 2).to_i`. If we pass "23" as binary string, it interprets bytes?
    # No, `OpenSSL::BN.new(str, 2)` means binary (big-endian) representation.
    # So if we want number 23, we should pack it as binary.
    
    expected_p = 23
    expected_g = 5
    
    pad_p = [expected_p].pack("C") # "23" is byte 23 (0x17)
    pad_g = [expected_g].pack("C")
    pad_y = [10].pack("C")
    
    payload = String.new
    [pad_p, pad_g, pad_y].each do |val|
      payload << [val.bytesize].pack("n")
      payload << val
    end
    
    result = Cinch::SASL::DhBlowfish.unpack_payload(payload)
    
    assert_equal 3, result.size
    assert_equal expected_p, result[0]
    assert_equal expected_g, result[1]
    assert_equal 10, result[2]
  end

  class MockCipher
    attr_accessor :key_len, :key
    def initialize(*args); end
    def encrypt; end
    def update(data); "encrypted"; end
  end

  test "generate returns valid base64 string" do
    # We need a valid payload for p, g, y
    # Small prime 23, g 5
    
    p_byte = [23].pack("C")
    g_byte = [5].pack("C")
    y_byte = [3].pack("C") # public key of server
    
    payload = String.new
    [p_byte, g_byte, y_byte].each do |val|
      payload << [val.bytesize].pack("n")
      payload << val
    end
    
    # Payload must be base64 encoded as input to generate
    b64_payload = Base64.strict_encode64(payload)
    
    # Stub OpenSSL::Cipher
    old_cipher = OpenSSL::Cipher
    OpenSSL.send(:remove_const, :Cipher)
    OpenSSL.const_set(:Cipher, MockCipher)
    
    begin
      # generate(user, password, payload)
      response = Cinch::SASL::DhBlowfish.generate("user", "pass", b64_payload)
      
      assert_instance_of String, response
      
      # Decode response
      decoded = Base64.decode64(response)
      
      # Response structure: [public_len, public_key, user, crypted_pass].pack("na*Z*a*")
      
      len = decoded.unpack1("n")
      assert len > 0
      
      # Verify minimal length
      assert decoded.size > 2 + len
    ensure
      OpenSSL.send(:remove_const, :Cipher)
      OpenSSL.const_set(:Cipher, old_cipher)
    end
  end
end
