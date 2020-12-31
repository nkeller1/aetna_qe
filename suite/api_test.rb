require File.expand_path('../support/test_helper', __dir__)

require 'minitest/autorun'

class ApiTest < Minitest::Test

  def test_no_api_key
    make_request('?s=star', 'http://www.omdbapi.com/')
    puts last_response.body
    parse_last_response_body = JSON.parse(last_response.body)

    # expect response to be JSON formatted
    assert_equal last_response.headers["Content-Type"], "application/json; charset=utf-8"
    assert_instance_of Hash, parse_last_response_body
    # expect correct error status code
    assert_equal last_response.status, 401
    assert_equal parse_last_response_body.key?('Response'), true
    assert_equal parse_last_response_body['Response'], 'False'
    assert_equal parse_last_response_body.key?('Error'), true
    assert_equal parse_last_response_body['Error'], 'No API key provided.'
  end

  def test_successful_response_for_search_of_thomas
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

  def test_using_i_param_page_1_is_accessable_on_imbd
    make_request("?apikey=#{ENV['OMDB_API_KEY']}&s=thomas", 'http://www.omdbapi.com/')
    parse_last_response_body = JSON.parse(last_response.body)
    search_results =  parse_last_response_body['Search']

    search_results.each do |result|
      id = result['imdbID']
      make_request("?apikey=#{ENV['OMDB_API_KEY']}&i=#{id}", 'http://www.omdbapi.com/')
      assert_equal last_response.status, 200
    end

  end

  def test_poster_link_validity_page_1
    make_request("?apikey=#{ENV['OMDB_API_KEY']}&s=thomas&page=1", 'http://www.omdbapi.com/')
    parse_last_response_body = JSON.parse(last_response.body)
    search_results =  parse_last_response_body['Search']

    search_results.each do |result|
      assert_instance_of (URI::HTTPS || URI::HTTP), URI.parse(result['Poster'])
    end
  end

  def test_invalid_poster_links_are_okay_on_page_3
    # additonal edge case for invalid poster links
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

  def test_no_duplicate_records_across_first_5_pages
      all_results = Array.new
      acc = 1
      until acc == 6
        make_request("?apikey=#{ENV['OMDB_API_KEY']}&s=thomas&page=#{acc}", 'http://www.omdbapi.com/')
        parse_page = JSON.parse(last_response.body)
        search_results = parse_page['Search']
        all_results << search_results
        acc += 1
      end
      all_results.flatten!

      imbdIDs = all_results.map do |result|
        result["imdbID"]
      end

      assert_equal imbdIDs.length, 50
      assert_equal imbdIDs.length, imbdIDs.uniq.length
  end

# additional testing I am curious about
  def test_imbdID_is_uniform_for_all_responses_page_1
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
      # verifies leading t's, that convert to INT 0, are not equal
      refute_match verify_id[0].to_i.to_s, verify_id[0]
      refute_match verify_id[1].to_i.to_s, verify_id[1]
    end
  end

  def test_passing_no_query_params_throws_error
    make_request("?apikey=#{ENV['OMDB_API_KEY']}", 'http://www.omdbapi.com/')
    parse_last_response_body = JSON.parse(last_response.body)

    assert_equal parse_last_response_body.key?('Response'), true
    assert_equal parse_last_response_body.key?('Error'), true
    assert_equal parse_last_response_body['Error'], 'Incorrect IMDb ID.'
  end

  def test_no_search_params_passed_throws_error
    # This is sending a 200 response. I would probably ask that a differnt code be
    # sent instead of 200 for an error
    make_request("?apikey=#{ENV['OMDB_API_KEY']}&s=", 'http://www.omdbapi.com/')
    parse_last_response_body = JSON.parse(last_response.body)

    assert_equal parse_last_response_body.key?('Response'), true
    assert_equal parse_last_response_body.key?('Error'), true
    assert_equal parse_last_response_body['Error'], 'Incorrect IMDb ID.'
  end

  def test_total_results_key_exists_on_succcessful_response
    make_request("?apikey=#{ENV['OMDB_API_KEY']}&s=thomas", 'http://www.omdbapi.com/')
    parse_last_response_body = JSON.parse(last_response.body)

    assert_equal parse_last_response_body.key?('totalResults'), true
  end

  def test_incorrect_datatypes_in_search_throws_error
    # This is sending a 200 response. I would probably ask that a differnt code be
    # sent instead of 200 for an error
    make_request("?apikey=#{ENV['OMDB_API_KEY']}&s=#{12.34}", 'http://www.omdbapi.com/')
    parse_last_response_body = JSON.parse(last_response.body)

    assert_equal parse_last_response_body.key?('Response'), true
    assert_equal parse_last_response_body.key?('Error'), true
    assert_equal parse_last_response_body['Error'], 'Movie not found!'
  end

  def test_passing_an_invalid_page_number_throws_error
    # This is sending a 200 response. I would probably ask that a differnt code be
    # sent instead of 200 for an error
    make_request("?apikey=#{ENV['OMDB_API_KEY']}&s=thomas&page=#{0.34}", 'http://www.omdbapi.com/')
    parse_last_response_body = JSON.parse(last_response.body)

    assert_equal parse_last_response_body.key?('Response'), true
    assert_equal parse_last_response_body.key?('Error'), true
    assert_equal parse_last_response_body['Error'], 'The offset specified in a OFFSET clause may not be negative.'
  end

  def test_passing_an_empty_search_throws_error
    # This is sending a 200 response. I would probably ask that a differnt code be
    # sent instead of 200 for an error
    make_request("?apikey=#{ENV['OMDB_API_KEY']}&s=", 'http://www.omdbapi.com/')
    parse_last_response_body = JSON.parse(last_response.body)

    assert_equal parse_last_response_body.key?('Response'), true
    assert_equal parse_last_response_body.key?('Error'), true
    assert_equal parse_last_response_body['Error'], 'Incorrect IMDb ID.'
  end

  def test_headers_are_as_expected
    # This test is a little bit of a reach. there is nothing in acceptacnce criteria about testing headers
    # or how they should look. I am really testing what is currently there to show
    # what i would test or ask about
    make_request("?apikey=#{ENV['OMDB_API_KEY']}&s=thomas", 'http://www.omdbapi.com/')

    assert_equal last_response.headers['content-type'], 'application/json; charset=utf-8'
    assert_equal last_response.headers['connection'], 'keep-alive'
    assert_equal last_response.headers['cache-control'], 'public, max-age=86400'
    assert_equal last_response.headers.key?('expires'), true
    assert_equal last_response.headers.key?('access-control-allow-origin'), true
    # Note: from my reading the X-Powered-By header is currently exposed on this API
    # it is my understanding that this should be hidden from all get responses
    # exposing an outdated (and possibly vulnerable) version may be an
    # invitation for people to try and attack it. Current key: "x-powered-by"=>"ASP.NET",
  end
end
