require 'em_test_helper'

class TestResolver < Test::Unit::TestCase
  def test_a
    EM.run {
      d = EM::DNS::Resolver.resolve "google.com"
      d.errback { assert false }
      d.callback { |r|
        assert r
        EM.stop
      }
    }
  end

  def test_bad_host
    EM.run {
      d = EM::DNS::Resolver.resolve "asdfasasdf"
      d.callback { assert false }
      d.errback  { assert true; EM.stop }
    }
  end

  def test_garbage
    assert_raises( ArgumentError ) {
      EM.run {
        EM::DNS::Resolver.resolve 123
      }
    }
  end

  def test_a_pair
    EM.run {
      d = EM::DNS::Resolver.resolve "google.com"
      d.errback { assert false }
      d.callback { |r|
        assert_kind_of(Array, r)
        assert r.size > 1
        EM.stop
      }
    }
  end

  def test_localhost
    EM.run {
      d = EM::DNS::Resolver.resolve "localhost"
      d.errback { assert false }
      d.callback { |r|
        assert_include(["127.0.0.1", "::1"], r.first)
        assert_kind_of(Array, r)

        EM.stop
      }
    }
  end

  def test_timer_cleanup
    EM.run {
      d = EM::DNS::Resolver.resolve "google.com"
      d.errback { assert false }
      d.callback { |r|
        # This isn't a great test, but it's hard to get more canonical
        # confirmation that the timer is cancelled
        assert_nil(EM::DNS::Resolver.socket.instance_variable_get(:@timer))

        EM.stop
      }
    }
  end

  def test_failure_timer_cleanup
    EM.run {
      d = EM::DNS::Resolver.resolve "asdfasdf"
      d.callback { assert false }
      d.errback {
        assert_nil(EM::DNS::Resolver.socket.instance_variable_get(:@timer))

        EM.stop
      }
    }
  end
end
