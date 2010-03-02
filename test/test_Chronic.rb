require 'chronic'
require 'test/unit'

class TestChronic < Test::Unit::TestCase
  
  def setup
    # Wed Aug 16 14:00:00 UTC 2006
    @now = Time.local(2006, 8, 16, 14, 0, 0, 0)
  end
  
  def test_post_normalize_am_pm_aliases
    # affect wanted patterns
    
    tokens = [Chronic::Token.new("5:00"), Chronic::Token.new("morning")]
    tokens[0].tag(Chronic::RepeaterTime.new("5:00"))
    tokens[1].tag(Chronic::RepeaterDayPortion.new(:morning))
    
    assert_equal :morning, tokens[1].tags[0].type
    
    tokens = Chronic.dealias_and_disambiguate_times(tokens, {})
    
    assert_equal :am, tokens[1].tags[0].type
    assert_equal 2, tokens.size
    
    # don't affect unwanted patterns
    
    tokens = [Chronic::Token.new("friday"), Chronic::Token.new("morning")]
    tokens[0].tag(Chronic::RepeaterDayName.new(:friday))
    tokens[1].tag(Chronic::RepeaterDayPortion.new(:morning))
    
    assert_equal :morning, tokens[1].tags[0].type
    
    tokens = Chronic.dealias_and_disambiguate_times(tokens, {})
    
    assert_equal :morning, tokens[1].tags[0].type
    assert_equal 2, tokens.size
  end
  
  def test_format_options
    non_us_date = Chronic.parse("12/07/1979", :format => [:day, :month, :year])
    us_date     = Chronic.parse("12/07/1979")
    non_us_expectation = Date.parse("1979/07/12")
    us_expectation = Date.parse("1979/12/07")
    
    assert_equal non_us_date.strftime("%d-%m-%Y"), non_us_expectation.strftime("%d-%m-%Y")
    assert_equal us_date.strftime("%d-%m-%Y"), us_expectation.strftime("%d-%m-%Y")
  end
  
  def test_guess
    span = Chronic::Span.new(Time.local(2006, 8, 16, 0), Time.local(2006, 8, 17, 0))
    assert_equal Time.local(2006, 8, 16, 12), Chronic.guess(span)
    
    span = Chronic::Span.new(Time.local(2006, 8, 16, 0), Time.local(2006, 8, 17, 0, 0, 1))
    assert_equal Time.local(2006, 8, 16, 12), Chronic.guess(span)
    
    span = Chronic::Span.new(Time.local(2006, 11), Time.local(2006, 12))
    assert_equal Time.local(2006, 11, 16), Chronic.guess(span)
  end
  
end