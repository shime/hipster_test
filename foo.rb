require "pry"

class Meme
  def i_can_has_cheezburger?
    "OHAI!"
  end

  def will_it_blend?
    "YES!"
  end
end

module Hipster
  class Test
    @@klasses = []

    def self.inherited(klass)
      @@klasses << klass
    end

    def self.children
      @@klasses
    end

    def assert_equal(actual, expected)
      raise unless actual == expected
    end

    def refute_match(actual, expected)
      raise unless ! assert_match(actual, expected)
    end

    def assert_match(actual, expected)
      !! actual =~ expected
    end

    def skip(*args); end
  end
end

class TestMeme < Hipster::Test
  def setup
    @meme = Meme.new
  end

  def test_that_kitty_can_eat
    assert_equal "OHAI!", @meme.i_can_has_cheezburger?
  end

  def test_that_it_will_not_blend
    refute_match /^no/i, @meme.will_it_blend?
  end

  def test_that_will_be_skipped
    skip "test this later"
  end
end

at_exit do 
  instance = Hipster::Test.children.first.new
  Hipster::Test.children.first.instance_methods(false).each do |met|
    if met =~ /^test_/
      instance.setup if instance.respond_to?(:setup)
      instance.send(met)
    end
  end
end
