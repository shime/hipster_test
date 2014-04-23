module Hipster
  class Test
    @@klasses = []

    def self.inherited(klass)
      @@klasses << klass
    end

    def self.children
      @@klasses
    end

    def assert(actual, expected, operator)
      Hipster::Tracker.assertions += 1
      if actual.send(operator, expected)
        print "."
      else
        Hipster::Tracker.failures << Hipster::Failure.new(actual, expected, operator, caller)
        print "F"
      end
    end

    def assert_equal(actual, expected)
      assert(actual, expected, "==")
    end

    def refute_match(actual, expected)
      assert(actual, expected, "!~")
    end

    def skip(*args)
      Hipster::Tracker.skips += 1
      print "S"
    end
  end

  class Tracker
    class << self
      attr_accessor :assertions, :failures, :skips, :runs
    end
    self.assertions, self.skips, self.runs = [0] * 3
    self.failures = []
  end

  class Failure
    OPERATORS_HUMANIZED = {
      "==" => "equal",
      "=~" => "match",
      "!~" => "not match"
    }
    attr_reader :actual, :expected, :operator, :trace
    def initialize(actual, expected, operator, trace)
      @actual, @expected, @operator = actual, expected, OPERATORS_HUMANIZED[operator]

      @trace = trace[1..-1]
    end
  end

  class Reporter
    def self.report
      start = Time.now 
      instance = Hipster::Test.children.first.new
      Hipster::Test.children.first.instance_methods(false).each do |met|
        if met =~ /^test_/
          Hipster::Tracker.runs += 1
          instance.setup if instance.respond_to?(:setup)
          instance.send(met)
        end
      end
      finish = Time.now
      run_time = (finish - start).round(6)
      puts "\n\n"
      failures = Hipster::Tracker.failures
      failures.each_with_index do |failure, i|
        puts "#{i + 1}) Failure: #{failure.trace.first}"
        puts "expected #{failure.expected.inspect} to #{failure.operator} #{failure.actual.inspect}"
        puts
      end
      puts "#{Hipster::Tracker.runs} runs, #{Hipster::Tracker.assertions} assertions, #{Hipster::Tracker.failures.count} failures, #{Hipster::Tracker.skips} skips"
      puts "Finished in #{run_time}s, #{(Hipster::Tracker.runs/run_time).round(4)} runs/s, #{(Hipster::Tracker.assertions/run_time).round(4)} assertions/s"
      puts
    end
  end
end

at_exit do 
  Hipster::Reporter.report
end
