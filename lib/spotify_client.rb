require 'rest-client'
require 'json'
require 'watir'
require 'uri'
require 'cgi'

class SpotifyClient
    attr_reader  :user_id

    def initialize(client_id, client_secret, redirect_uri: "http://localhost/")
        @client_id = client_id
        @client_secret = client_secret    
        @redirect_uri = redirect_uri 
        self.auth
    end
    
    # def self.new_token(token)
    #     @token
    #     new()
    # end

    #return a fresh token
    def token
        #checks if token expired and refresh it 
        now = Time.new.to_i
        if now > (@token_birth + @token_expiration - 100) then 
            self.refresh_token
        else
            @token
        end
    end 

    def get_me(token_type:'Bearer') 
        url = 'https://api.spotify.com/v1/me'
        headers={
            "Authorization"=> token_type + ' ' + self.token,
        }
        response = RestClient.get(url, headers)
        response = JSON.parse(response.body)
        @user_id = response['id']
    end
    

    protected
    #all steps implemented in one function
    def auth 
        url = build_auth_url
        link = get_acces_link(url)
        code = parse_url(link)
        token = get_token(code)
        get_me 
    end


    def build_auth_url
        base_url = 'https://accounts.spotify.com/authorize'
        scopes= "playlist-modify-public playlist-modify-private playlist-read-private user-read-email user-read-private"
        "#{base_url}?client_id=#{@client_id}&response_type=code&scope=#{scopes}&redirect_uri=#{@redirect_uri}" 
    end

    def get_acces_link(url)
        browser = Watir::Browser.new
        browser.goto url

        # Watir::Wait.until { } # have a 30s time out exception
        # loop that will stop broswer from stoping until 
        # page with given host will be opend
        # default: localhost
        until (URI(browser.url).host == URI(@redirect_uri).host)
            sleep 1
        end
        response_url = browser.url
        browser.close
        response_url
    end
    
    # return code from acces_link
    # raise error if you denied accesing data 
    def parse_url(url)
        uri = URI(url)
        params = CGI.parse(uri.query)
        if params['error'] != "access_denied" then
            params['code'] = params['code'][0]
            params['code'] 
        else
            raise 'You must accept'
        end
    end

    # first request for token
    def get_token(code)
        url = 'https://accounts.spotify.com/api/token'
        body = {
                'grant_type' => "authorization_code",
                'code'=> code,
                'redirect_uri'=> @redirect_uri,
                'client_id'=> @client_id,
                'client_secret'=> @client_secret
            }
        response = RestClient.post(url, body)
        response = JSON.parse(response.body)
        @token_birth = Time.new().to_i
        @token_expiration = response['expires_in'].to_i
        @refresh_token = response['refresh_token']
        @token = response['access_token']
    end

    # for updating token every time it expires
    def refresh_token
        url = 'https://accounts.spotify.com/api/token'
        headers ={ 
          "Content-Type" => "application/x-www-form-urlencoded"
        } 
        body = {
            'grant_type' => "refresh_token",
            'refresh_token'=> @refresh_token,
            'client_id' => @client_id,
            'client_secret' => @client_secret
        }
        response = RestClient.post(url,body,headers)
        response = JSON.parse(response.body)
        @token_birth = Time.new().to_i
        @token_expiration = response['expires_in'].to_i
        @token = response['access_token']
    end

    
end

