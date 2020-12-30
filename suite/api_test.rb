require File.expand_path('../support/test_helper', __dir__)

require 'minitest/autorun'

class ApiTest < Minitest::Test

  def test_no_api_key
    skip
    make_request('?s=star', 'http://www.omdbapi.com/')
    puts last_response.body
    parse_last_response_body = JSON.parse(last_response.body)

    # expect response to be JSON formatted
    assert_equal last_response.headers["Content-Type"], "application/json; charset=utf-8"
    assert_instance_of Hash, parse_last_response_body
    # expect correct error status code
    assert_equal last_response.status, 401
    assert_equal parse_last_response_body.key?('Response'), true
    assert_equal parse_last_response_body.key?('Error'), true
    assert_equal parse_last_response_body['Error'], 'No API key provided.'
  end

  def test_successful_response_for_thomas
    make_request("?apikey=#{ENV['OMDB_API_KEY']}&s=thomas", 'http://www.omdbapi.com/')
    parse_last_response_body = JSON.parse(last_response.body)
    search_results =  parse_last_response_body['Search']

    assert_equal last_response.status, 200
    assert_equal last_response.headers["Content-Type"], "application/json; charset=utf-8"
    assert_instance_of Hash, parse_last_response_body
    assert_instance_of Array, search_results
    assert_equal parse_last_response_body.key?('Search'), true
    search_results.each do |result|
      # Verify all titles are a relevant match
      assert_includes result['Title'], 'Thomas' || 'thomas'
      # Verify keys include Title, Year, imdbID, Type, and Poster for all records in the response
      assert_equal result.key?('Title'), true
      assert_equal result.key?('Year'), true
      assert_equal result.key?('imdbID'), true
      assert_equal result.key?('Type'), true
      assert_equal result.key?('Poster'), true
      assert_instance_of Hash, result
      # Expect 'Year' Key to be formatted correctly
      assert_equal Date.new(result['Year'].to_i).gregorian?, true
      #expect poster to be a URL
      assert_includes result['Poster'], 'http'
    end

  end
end
