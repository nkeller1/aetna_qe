Encoding.default_external = Encoding::UTF_8
Encoding.default_internal = Encoding::UTF_8

require 'faraday'
require 'json'
require 'minitest/autorun'
require 'minitest/reporters'
require 'pry'

def test_client
  @test_client ||= Faraday.new do |f|
    f.adapter :net_http
  end
end

def get(full_path)
  test_client.get(full_path)
end

def make_request(params, url = ENV['BASE_URL'])
  full_path = "#{url}#{params}"
  res = get(full_path)
  @last_response = res
  @curl = set_curl(res)
  res
end

def last_response
  @last_response
end

def last_curl
  @curl
end

def set_curl(res)
  <<~CURL
    See: curl -X "#{res.env.method.upcase}" "#{res.env.url}"
  CURL
end
