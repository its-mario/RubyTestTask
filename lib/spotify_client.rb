# frozen_string_literal: true

require 'rest-client'
require 'json'
require 'watir'
require 'uri'
require 'cgi'

# This class represent a spotify client implementation
class SpotifyClient
  # class is instancing with spotify-client_id and spotify-client_secret
  #
  # on instancing it auth user using a browser window
  #
  # it has a token method
  # token method always return a valid value of token (it automatically refresh tokenehen this exipire)
  #
  # parameters for instacing (spotify-client-id and spotify-client-secret)

  attr_reader :user_id

  def initialize(client_id, client_secret, redirect_uri: 'http://localhost/')
    @client_id = client_id
    @client_secret = client_secret
    @redirect_uri = redirect_uri
    auth
  end

  # def self.new_token(token)
  #   @token
  #   new()
  # end

  # return a fresh token
  def token
    # checks if token expired and refresh it
    now = Time.new.to_i
    if now > (@token_birth + @token_expiration - 100)
      refresh_token
    else
      @token
    end
  end

  def get_me(token_type: 'Bearer')
    url = 'https://api.spotify.com/v1/me'
    headers = { 'Authorization' => "#{token_type} #{token}" }
    response = RestClient.get(url, headers)
    response = JSON.parse(response.body)
    @user_id = response['id']
  end

  protected

  # all steps implemented in one function
  def auth
    url = build_auth_url
    link = get_acces_link(url)
    code = parse_url(link)
    get_token(code)
    get_me
  end

  def build_auth_url
    base_url = 'https://accounts.spotify.com/authorize'
    scopes = 'playlist-modify-public playlist-modify-private playlist-read-private user-read-email user-read-private'
    "#{base_url}?client_id=#{@client_id}&response_type=code&scope=#{scopes}&redirect_uri=#{@redirect_uri}"
  end

  def get_acces_link(url)
    browser = Watir::Browser.new
    browser.goto url

    # Watir::Wait.until { } # have a 30s time out exception
    # loop that will stop broswer from stoping until
    # page with given host will be opend
    # default: localhost
    sleep 1 until URI(browser.url).host == URI(@redirect_uri).host
    response_url = browser.url
    browser.close
    response_url
  end

  # return code from acces_link
  # raise error if you denied accesing data
  def parse_url(url)
    uri = URI(url)
    params = CGI.parse(uri.query)
    raise 'You must accept' if params['error'] == 'access_denied'

    params['code'][0]
  end

  # first request for token
  def get_token(code)
    url = 'https://accounts.spotify.com/api/token'
    body = {
      'grant_type' => 'authorization_code',
      'code' => code,
      'redirect_uri' => @redirect_uri,
      'client_id' => @client_id,
      'client_secret' => @client_secret
    }
    headers = { 'Content-Type' => 'application/x-www-form-urlencoded' }
    response = JSON.parse(RestClient.post(url, body, headers))
    init_token(response['access_token'], response['expires_in'], refresh_token: response['refresh_token'])
  end

  # for updating token every time it expires
  def refresh_token
    url = 'https://accounts.spotify.com/api/token'
    body = {
      'grant_type' => 'refresh_token',
      'refresh_token' => @refresh_token,
      'client_id' => @client_id,
      'client_secret' => @client_secret
    }
    headers = { 'Content-Type' => 'application/x-www-form-urlencoded' }
    response = JSON.parse(RestClient.post(url, body, headers))
    init_token(response['access_token'], response['expires_in'])
  end

  def init_token(token, token_expiration, refresh_token:)
    @refresh_token = refresh_token unless refresh_token.nil?
    @token_birth = Time.now.to_i
    @token_expiration = token_expiration.to_i
    @token = token
  end
end
