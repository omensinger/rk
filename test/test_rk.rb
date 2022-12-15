require "minitest/autorun"
require "./lib/rk.rb"

class TestRk < Minitest::Test
  extend Minitest::Spec::DSL

  let(:simple_user_10) { ["user", 10] }
  let(:class_using_rk) do
    class Test
      def key
        rk("user", 10)
      end
    end

    Test.new.key
  end

  let(:keys) { { user: "user", "statistics" => "stats", "session" => :sess } }

  def setup
    Rk.configure do |config|
      config.separator = ":"
      config.prefix = ""
      config.suffix = ""
    end
  end

  def test_simple_key
    assert_equal simple_user_10.join(":"), rk(simple_user_10)
  end

  def test_long_key
    a = [*1..1000]
    s = a.join(":") # "1:2:3:4:5:6:7:8:9:10:11:...:1000"
    assert_equal s, rk(a)
  end

  def test_key_prefix
    rk.prefix = "myapp"
    assert_equal "myapp:#{simple_user_10.join(":")}", rk(simple_user_10)
  end

  def test_key_suffix
    rk.suffix = "test"
    assert_equal "#{simple_user_10.join(":")}:test", rk(simple_user_10)
  end

  def test_key_prefix_and_suffix
    rk.prefix = "myapp"
    rk.suffix = "test"
    assert_equal "myapp:#{simple_user_10.join(":")}:test", rk(simple_user_10)
  end

  def test_change_separator
    rk.separator = "-"
    assert_equal simple_user_10.join("-"), rk(simple_user_10)
  end

  def test_use_defined_key_element
    rk.user = "user"
    assert_equal simple_user_10.join(":"), rk(rk.user, 10)
  end

  def test_use_undefined_key_element
    assert_raises NoMethodError do
      rk.something
    end
  end

  def test_rk_globally_available
    assert_equal simple_user_10.join(":"), class_using_rk
  end

  def test_set_keys
    rk.keys = keys
    keys.each_pair do |key, val|
      # rk always return a string for a key, thus val.to_s
      assert_equal rk.send(key), val.to_s
    end
  end

  def test_get_keys
    rk.keys = keys

    # Build hash from "keys", keys/values converted to strings
    keys_as_strings = Hash[keys.map { |key, val| [key.to_s, val.to_s] }]

    assert_equal keys_as_strings, rk.keys
  end

  def test_can_access_config_attributes
    Rk.configure("test") do |config|
      config.separator = ":"
      config.prefix = "pre"
      config.suffix = "suf"
    end

    assert_equal ":", test_rk.separator
    assert_equal "pre", test_rk.prefix
    assert_equal "suf", test_rk.suffix
  end

  def test_allow_second_setting
    Rk.configure("foo") do |config|
      config.separator = "-"
    end

    assert_equal "-", foo_rk.separator
    assert_equal ":", rk.separator
  end

  def test_named_rk_creates_key
    Rk.configure("foo") do |config|
      config.prefix = "foo"
      config.separator = "-"
    end
    assert_equal "foo-bar", foo_rk("bar")
  end
end
