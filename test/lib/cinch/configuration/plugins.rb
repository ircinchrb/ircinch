# frozen_string_literal: true

require_relative "../../../test_helper"
require "cinch/configuration/plugins"

class PluginsConfigurationTest < TestCase
  def setup
    @plugins_config = Cinch::Configuration::Plugins.new
  end

  test "default config values" do
    defaults = Cinch::Configuration::Plugins.default_config
    assert_equal [], defaults[:plugins]
    assert_equal(/^!/, defaults[:prefix])
    assert_nil defaults[:suffix]
    assert_instance_of Hash, defaults[:options]
  end

  test "load sets plugin usage with constants" do
    # Can't use real classes easily unless we define them or use existing ones.
    # We can use String, Array, etc.
    config = {plugins: ["String", "Array"]}
    @plugins_config.load(config)

    assert_equal [String, Array], @plugins_config[:plugins]
  end

  test "load merges options" do
    @plugins_config[:options][String] = {existing: 1}

    config = {options: {"String" => {new: 2}}}
    @plugins_config.load(config)

    assert_equal({existing: 1, new: 2}, @plugins_config[:options][String])
  end

  test "load sets other options" do
    config = {prefix: "!", suffix: "?"}
    @plugins_config.load(config)

    assert_equal "!", @plugins_config[:prefix]
    assert_equal "?", @plugins_config[:suffix]
  end
end
