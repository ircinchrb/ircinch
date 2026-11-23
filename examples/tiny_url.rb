# frozen_string_literal: true

require "json"
require "net/http"
require "openssl"
require "uri"

class TinyURLClient
  ENDPOINT = URI("https://api.tinyurl.com/create")

  def initialize(token)
    @token = token
  end

  def shorten(url)
    target = URI.parse(url)
    return "Enter a valid HTTP or HTTPS URL." unless target.is_a?(URI::HTTP) && target.host && !target.userinfo

    request = Net::HTTP::Post.new(ENDPOINT)
    request["Authorization"] = "Bearer #{@token}"
    request["Content-Type"] = "application/json"
    request["Accept"] = "application/json"
    request.body = JSON.generate(url: url)

    response = Net::HTTP.start(ENDPOINT.host, ENDPOINT.port, use_ssl: true, open_timeout: 5, read_timeout: 5) do |http|
      http.request(request)
    end
    if response.is_a?(Net::HTTPSuccess)
      body = JSON.parse(response.body)
      data = body["data"] if body.is_a?(Hash)
      result = data["tiny_url"] if data.is_a?(Hash)
      return result if result.is_a?(String) && !result.empty?
    end

    "TinyURL could not shorten that URL."
  rescue URI::InvalidURIError
    "Enter a valid HTTP or HTTPS URL."
  rescue JSON::ParserError, IOError, SystemCallError, SocketError, Timeout::Error, OpenSSL::SSL::SSLError
    "TinyURL is unavailable. Try again later."
  end
end
