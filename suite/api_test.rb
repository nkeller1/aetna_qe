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
    skip
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
    end
  end

  def test_i_parameter_is_accessable_by_imbdID
    skip
    make_request("?apikey=#{ENV['OMDB_API_KEY']}&s=thomas&page=1", 'http://www.omdbapi.com/')
    parse_last_response_body = JSON.parse(last_response.body)
    search_results =  parse_last_response_body['Search']
    search_results.each do |result|
      verify_id = result['imdbID'].split(//)
      assert_equal verify_id.length, 9
      assert_equal verify_id[0], 't'
      assert_equal verify_id[1], 't'
      # verifies that the trailing int's are actual int's
      assert_equal verify_id[2].to_i.to_s, verify_id[2]
      assert_equal verify_id[3].to_i.to_s, verify_id[3]
      assert_equal verify_id[4].to_i.to_s, verify_id[4]
      assert_equal verify_id[5].to_i.to_s, verify_id[5]
      assert_equal verify_id[6].to_i.to_s, verify_id[6]
      assert_equal verify_id[7].to_i.to_s, verify_id[7]
      assert_equal verify_id[8].to_i.to_s, verify_id[8]
      # verifies leading t's, that convert to a 0, are not equal
      refute_match verify_id[0].to_i.to_s, verify_id[0]
      refute_match verify_id[1].to_i.to_s, verify_id[1]
    end
  end

  def test_poster_link_validity_page_1
    skip
    make_request("?apikey=#{ENV['OMDB_API_KEY']}&s=thomas&page=1", 'http://www.omdbapi.com/')
    parse_last_response_body = JSON.parse(last_response.body)
    search_results =  parse_last_response_body['Search']

    search_results.each do |result|
      assert_instance_of (URI::HTTPS || URI::HTTP), URI.parse(result['Poster'])
    end
  end

  def test_invalid_poster_links_are_okay_on_page_3
    skip
    make_request("?apikey=#{ENV['OMDB_API_KEY']}&s=thomas&page=3", 'http://www.omdbapi.com/')
    parse_last_response_body = JSON.parse(last_response.body)
    search_results =  parse_last_response_body['Search']

    search_results.each do |result|
      if !URI.parse(result['Poster']).is_a?(URI::HTTPS)
        assert_equal result['Poster'], "N/A"
      else
        assert_instance_of (URI::HTTPS || URI::HTTP), URI.parse(result['Poster'])
      end
    end

  end
end
