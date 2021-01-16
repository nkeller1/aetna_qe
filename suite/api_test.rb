require File.expand_path('../support/test_helper', __dir__)

require 'minitest/autorun'

class ApiTest < Minitest::Test

  def test_no_api_key
    make_request('?s=star', 'http://www.omdbapi.com/')
    # puts last_response.body
    parse_last_response_body = JSON.parse(last_response.body)

    assert_equal parse_last_response_body['Response'], 'False'
    assert_equal parse_last_response_body['Error'], 'No API key provided.'
    refute_equal last_response.status, 200
  end

  def test_successful_response_for_search_of_thomas
    make_request("?apikey=#{ENV['OMDB_API_KEY']}&s=thomas", 'http://www.omdbapi.com/')
    # puts last_response.body
    begin
      parse_last_response_body = JSON.parse(last_response.body)
      # the following line is to check that the error is being properly handled.
      # parse_last_response_body = JSON.parse('last_response.body')
    rescue JSON::ParserError
      puts 'JSON Parser Error, check that last_response is a JSON object'
    end

    search_results =  parse_last_response_body['Search']

    assert_equal parse_last_response_body.key?('Search'), true
    search_results.each do |result|
      # Verify all titles are a relevant match
      assert_includes result['Title'].downcase, 'thomas'
      # Verify keys include Title, Year, imdbID, Type, and Poster for all records in the response
      assert_equal result.key?('Title'), true
      assert_equal result.key?('Year'), true
      assert_equal result.key?('imdbID'), true
      assert_equal result.key?('Type'), true
      assert_equal result.key?('Poster'), true
      assert_instance_of Hash, result
      # Expect 'Year' Key to be formatted correctly
      # This method will allow the '1984-' to pass since the date comes after the
      # "-" but if the "-" (example: -1985) comes before the year this test will fail since that is making
      # the year a negative value instead of a type-o
      assert_equal Date.new(result['Year'].to_i).gregorian?, true
    end
  end

  def test_using_i_param_page_1_is_accessable_on_imbd
    make_request("?apikey=#{ENV['OMDB_API_KEY']}&s=thomas", 'http://www.omdbapi.com/')
    # puts last_response.body
    parse_last_response_body = JSON.parse(last_response.body)
    search_results =  parse_last_response_body['Search']

    search_results.each do |result|
      id = result['imdbID']
      make_request("?apikey=#{ENV['OMDB_API_KEY']}&i=#{id}", 'http://www.omdbapi.com/')
      assert_equal last_response.status, 200
    end

  end

  def test_poster_link_validity_page_1
    make_request("?apikey=#{ENV['OMDB_API_KEY']}&s=thomas&page=3", 'http://www.omdbapi.com/')
    # puts last_response.body
    parse_last_response_body = JSON.parse(last_response.body)
    search_results =  parse_last_response_body['Search']
    search_results.each do |result|
      poster_link = result['Poster']
      begin
        response = make_request(poster_link)
      rescue
        assert_equal poster_link, 'N/A'
      else
        assert_equal response.status, 200
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
      # I felt like using the puts for all_results was more beneficial then 5 last_responses
      # puts all_results
      imbdIDs = all_results.map do |result|
        result["imdbID"]
      end

      assert_equal imbdIDs.length, 50
      assert_equal imbdIDs.length, imbdIDs.uniq.length
  end

# additional testing I am curious about
  def test_imbdID_is_uniform_for_all_requests_on_page_1
    make_request("?apikey=#{ENV['OMDB_API_KEY']}&s=thomas&page=1", 'http://www.omdbapi.com/')
    # puts last_response.body
    parse_last_response_body = JSON.parse(last_response.body)
    search_results =  parse_last_response_body['Search']

    def is_numeric?(numeric_id)
      numeric_id.match(/\A[+-]?\d+?(\.\d+)?\Z/) == nil ? false : true
    end

    search_results.each do |result|
      imdbID = result['imdbID']
      assert_equal imdbID.length, 9
      assert_equal imdbID[0..1], 'tt'
      assert_equal is_numeric?(imdbID[2..8]), true
    end
  end

  def test_passing_no_query_params_throws_error
    make_request("?apikey=#{ENV['OMDB_API_KEY']}", 'http://www.omdbapi.com/')
    # puts last_response.body
    parse_last_response_body = JSON.parse(last_response.body)

    assert_equal parse_last_response_body.key?('Response'), true
    assert_equal parse_last_response_body.key?('Error'), true
    assert_equal parse_last_response_body['Error'], 'Incorrect IMDb ID.'
  end

  def test_no_search_params_passed_throws_error
    # This is sending a 200 response. I would probably ask that a differnt code be
    # sent instead of 200 for an error
    make_request("?apikey=#{ENV['OMDB_API_KEY']}&s=", 'http://www.omdbapi.com/')
    # puts last_response.body
    parse_last_response_body = JSON.parse(last_response.body)

    assert_equal parse_last_response_body.key?('Response'), true
    assert_equal parse_last_response_body.key?('Error'), true
    assert_equal parse_last_response_body['Error'], 'Incorrect IMDb ID.'
  end

  def test_pass_in_nil_to_search_throws_error
    # This is sending a 200 response. I would probably ask that a differnt code be
    # sent instead of 200 for an error
    make_request("?apikey=#{ENV['OMDB_API_KEY']}&s=#{nil}", 'http://www.omdbapi.com/')
    # puts last_response.body
    parse_last_response_body = JSON.parse(last_response.body)

    assert_equal parse_last_response_body.key?('Response'), true
    assert_equal parse_last_response_body.key?('Error'), true
    assert_equal parse_last_response_body['Error'], 'Incorrect IMDb ID.'
  end

  def test_incorrect_api_key
    make_request('?apikey=WRONG_API_KEY&?s=star', 'http://www.omdbapi.com/')
    # puts last_response.body
    parse_last_response_body = JSON.parse(last_response.body)

    assert_equal parse_last_response_body.key?('Response'), true
    assert_equal parse_last_response_body['Response'], 'False'
    assert_equal parse_last_response_body.key?('Error'), true
    assert_equal parse_last_response_body['Error'], 'Invalid API key!'
  end

  def test_nil_passed_as_api_key
    make_request("?apikey=#{nil}&?s=star", 'http://www.omdbapi.com/')
    # puts last_response.body
    parse_last_response_body = JSON.parse(last_response.body)

    assert_equal parse_last_response_body.key?('Response'), true
    assert_equal parse_last_response_body['Response'], 'False'
    assert_equal parse_last_response_body.key?('Error'), true
    assert_equal parse_last_response_body['Error'], 'No API key provided.'
  end

  def test_total_results_key_exists_on_succcessful_response
    make_request("?apikey=#{ENV['OMDB_API_KEY']}&s=thomas", 'http://www.omdbapi.com/')
    # puts last_response.body
    parse_last_response_body = JSON.parse(last_response.body)

    assert_equal parse_last_response_body.key?('totalResults'), true
  end

  def test_incorrect_datatypes_in_search_throws_error
    # This is sending a 200 response. I would probably ask that a differnt code be
    # sent instead of 200 for an error
    make_request("?apikey=#{ENV['OMDB_API_KEY']}&s=#{12.34}", 'http://www.omdbapi.com/')
    # puts last_response.body
    parse_last_response_body = JSON.parse(last_response.body)

    assert_equal parse_last_response_body.key?('Response'), true
    assert_equal parse_last_response_body.key?('Error'), true
    assert_equal parse_last_response_body['Error'], 'Movie not found!'
  end

  def test_passing_an_invalid_page_number_throws_error
    # This is sending a 200 response. I would probably ask that a differnt code be
    # sent instead of 200 for an error
    make_request("?apikey=#{ENV['OMDB_API_KEY']}&s=thomas&page=#{0.34}", 'http://www.omdbapi.com/')
    # puts last_response.body
    parse_last_response_body = JSON.parse(last_response.body)

    assert_equal parse_last_response_body.key?('Response'), true
    assert_equal parse_last_response_body.key?('Error'), true
    assert_equal parse_last_response_body['Error'], 'The offset specified in a OFFSET clause may not be negative.'
  end

  def test_passing_an_empty_search_throws_error
    # This is sending a 200 response. I would probably ask that a differnt code be
    # sent instead of 200 for an error
    make_request("?apikey=#{ENV['OMDB_API_KEY']}&s=", 'http://www.omdbapi.com/')
    # puts last_response.body
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
    # puts last_response.body

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
