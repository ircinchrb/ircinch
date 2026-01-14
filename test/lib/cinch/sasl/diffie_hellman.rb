# frozen_string_literal: true

require_relative "../../../test_helper"
require "cinch/sasl/diffie_hellman"

class DiffieHellmanTest < TestCase
  def setup
    # Small primes for testing to keep it fast
    @p = 23
    @g = 5
    @q = 22 # p-1? No, q is usually (p-1)/2 or similar but here code takes simple args
    # Code: @x = rand(@q)

    @dh = Cinch::SASL::DiffieHellman.new(@p, @g, @q)
  end

  test "initialize sets attributes" do
    assert_equal 23, @dh.p
    assert_equal 5, @dh.g
    assert_equal 22, @dh.q
  end

  test "generate creates valid public key" do
    pub_key = @dh.generate
    assert pub_key.is_a?(Integer)
    assert pub_key >= 1
    assert pub_key < @p
  end

  test "secret calculation matches" do
    # Alice
    alice = Cinch::SASL::DiffieHellman.new(23, 5, 23)
    alice_pub = alice.generate

    # Bob
    bob = Cinch::SASL::DiffieHellman.new(23, 5, 23)
    bob_pub = bob.generate

    # Shared secret
    alice_secret = alice.secret(bob_pub)
    bob_secret = bob.secret(alice_pub)

    assert_equal alice_secret, bob_secret
  end
end
