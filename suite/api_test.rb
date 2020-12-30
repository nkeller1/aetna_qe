require File.expand_path('../support/test_helper', __dir__)

require 'minitest/autorun'

class ApiTest < Minitest::Test

  def test_no_api_key
    make_request('?s=star', 'http://www.omdbapi.com/')
    puts last_response.body
    parse_last_response_body = JSON.parse(last_response.body)

    # expect a JSON response
    assert_equal last_response.headers["Content-Type"], "application/json; charset=utf-8"
    # expect correct error status code
    assert_equal last_response.status, 401
    assert_equal parse_last_response_body.key?('Response'), true
    assert_equal parse_last_response_body.key?('Error'), true
    assert_equal parse_last_response_body['Error'], 'No API key provided.'
  end

  def test_titles_are_relevant_match
    skip
    make_request("?apikey=#{ENV['OMDB_API_KEY']}&s=star", 'http://www.omdbapi.com/')
    puts last_response.body

  end
end
