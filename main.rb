require 'rest-client'
require 'watir'
require 'uri'
require 'cgi'

CLIENT_ID = 'f702eb662a36476aa97ef15f5e39948b'
CLIENT_SECRET = '02271040a59e4e2aa1a70ed908a83e0f'
REDIRECT_URI = 'http://localhost/'

def build_auth_url(client_id, redirect_uri)
    base_url = 'https://accounts.spotify.com/authorize'
    "#{base_url}?client_id=#{client_id}&response_type=code&redirect_uri=#{redirect_uri}" 
end

def get_acces_link(url)
    browser = Watir::Browser.new
    browser.goto url

    Watir::Wait.until {URI(browser.url).host == 'localhost'}
    response_url = browser.url
    browser.close
    response_url
end

# add support for errors
def parse_url(url)
    uri = URI(url)
    params = CGI.parse(uri.query)

    params['code'] = params['code'][0]
    params
end


def exchange_code(codul)
    url = 'https://accounts.spotify.com/api/token'
    body = {'grant_type' => "authorization_code", 'code'=> codul, 'redirect_uri'=> REDIRECT_URI , 'client_id'=> CLIENT_ID, 'client_secret'=> CLIENT_SECRET}

    response = RestClient.post(url, body)
    #puts response.body
    JSON.parse(response.body)
end


def get_me(token, token_type='Bearer') 
    url = 'https://api.spotify.com/v1/me'
    response = RestClient.get(url, headers={"Authorization"=>token_type + ' ' + token})
    #puts response
    #response
end

def crete_playlist(user_id, token, token_type)
    headers={"Authorization"=>token_type + ' ' + token, "Content-Type"=> "application/json"}
    url = "https://api.spotify.com/v1/users/#{user_id}/playlists"
    response = RestClient.post(url, {"name"=> "My new playlist"}.to_json)
end

def add_songs()
    playlist = [
        'https://open.spotify.com/track/56pvqFKGXPjubh5eY6sOlv?si=6a919798b5f9464f'
    ]
end

def main
    url = build_auth_url CLIENT_ID, REDIRECT_URI
    puts url
    link = get_acces_link url
    puts link
    params = parse_url(link)
    puts params
    acces_token = exchange_code(params['code'])
    puts acces_token
    me = get_me(acces_token['access_token'])
    puts me


end