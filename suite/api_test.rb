require File.expand_path('../support/test_helper', __dir__)

require 'minitest/autorun'

class ApiTest < Minitest::Test

  def test_no_api_key
    make_request('?s=star', 'http://www.omdbapi.com/')
    puts last_response.body
    # TODO: Add the assertion described in readme
  end

  def test_titles_are_relevant_match
    make_request("?apikey=#{ENV['OMDB_API_KEY']}&s=star", 'http://www.omdbapi.com/')
    puts last_response.body


  end
end
