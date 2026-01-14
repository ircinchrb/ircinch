# frozen_string_literal: true

require_relative "../../test_helper"
require "cinch/pattern"

class PatternTest < TestCase
  test "obj_to_r returns regexp as is" do
    r = /foo/
    assert_same r, Cinch::Pattern.obj_to_r(r)
  end

  test "obj_to_r returns nil as is" do
    assert_nil Cinch::Pattern.obj_to_r(nil)
  end

  test "obj_to_r converts string to escaped regexp" do
    r = Cinch::Pattern.obj_to_r("foo.")
    assert_equal(/foo\./, r)
  end

  test "obj_to_r handles anchors" do
    assert_equal(/^foo/, Cinch::Pattern.obj_to_r("foo", :start))
    assert_equal(/foo$/, Cinch::Pattern.obj_to_r("foo", :end))
  end

  test "resolve_proc recursively resolves procs" do
    p = proc { proc { "val" } }
    assert_equal "val", Cinch::Pattern.resolve_proc(p)
  end

  test "generate raises error for unsupported type" do
    assert_raises(ArgumentError) do
      Cinch::Pattern.generate(:unknown, "arg")
    end
  end

  test "generate creates ctcp pattern" do
    p = Cinch::Pattern.generate(:ctcp, "VERSION")
    assert_instance_of Cinch::Pattern, p
    # Pattern matches inner CTCP content
    r = p.to_r
    assert_match(r, "VERSION")
    assert_match(r, "VERSION arg")
    refute_match(r, "OTHER")
  end

  test "to_r handles simple regexp pattern" do
    p = Cinch::Pattern.new(nil, /foo/, nil)
    # Checks if it matches "foo"
    assert_match(p.to_r, "foo")
  end

  test "to_r handles prefix and suffix" do
    p = Cinch::Pattern.new(/^/, /foo/, /$/)
    assert_match(p.to_r, "foo")
    refute_match(p.to_r, " bar foo ")
  end

  test "to_r resolves strings to regexps with escaping" do
    p = Cinch::Pattern.new("pre.", "foo.", "suf.")
    # Should match "pre.foo.suf." strictly (anchored by implementation)
    # The implementation wraps in ^...$ if pattern is not Regexp
    r = p.to_r
    assert_match(r, "pre.foo.suf.")
    refute_match(r, "preXfooXsufX")
  end

  test "to_r resolves procs" do
    # Strings in procs are escaped
    p = Cinch::Pattern.new(proc { "^" }, proc { "foo" }, proc { "$" })
    r = p.to_r
    # Matches literal "^foo$"
    assert_match(r, "^foo$")
  end

  test "generate escapes argument" do
    p = Cinch::Pattern.generate(:ctcp, "FOO.")
    r = p.to_r
    # Should match "FOO." literally, not "FOO" followed by any char
    assert_match(r, "FOO.")
    refute_match(r, "FOOX")
  end
end
