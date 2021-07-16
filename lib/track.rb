# frozen_string_literal: true

require 'rest-client'
require 'json'
require_relative 'spotify_client'

TOKEN_TYPE = 'Bearer '

# This class represent ruby implementation of spotify-track
class Track
  #
  # it could be insancing in 3 ways:
  #   - passing alll attributes directly
  #     Track.new({
  #       name: Name,
  #       id: Id,
  #       artist_name: ArtistName
  #       ...
  #     })
  #   - passing a json-object[String/Hash] of track
  #     Track.parse(json/object)
  #   - passing id and spotify-client for getting data of this track
  #     Track.by_id(id, spotify_client)
  #
  # also class has extra method:
  #   - Track.to_uri(id) -convert id into uri
  #
  # Class has to_json method that return JSON-object of instance

  attr_reader :id, :name, :artist_name, :album_name, :spotify_url

  def initialize(args)
    @id = args[:id]
    @name = args[:name]
    @artist_name = args[:artist_name]
    @album_name = args[:album_name]
    @spotify_url = args[:spotify_url]
    @as_hash = args
  end

  def self.to_uri(id)
    "spotify:track:#{id}"
  end

  def self.by_id(id, spotify_client)
    url = "https://api.spotify.com/v1/tracks/#{id}"
    headers = {
      'Authorization' => TOKEN_TYPE + spotify_client.token
    }
    response = RestClient.get(url, headers)
    response = JSON.parse(response)
    parse(response)
  end

  def to_uri
    "spotify:track:#{@id}"
  end

  def to_json(*options)
    @as_hash.to_json options
  end

  def self.parse(args)
    # check type
    unless args.instance_of?(String) || args.instance_of?(Hash)
      raise 'wrong type args must be of type Hash or String(JSON)'
    end

    args = JSON.parse(args) if args.instance_of?(String)
    # if track has more than one artist
    if args['artists'].length > 1
      names = args['artists'].map { |artist| artist['name'] }
      artists = names.join(', ')
    else
      artists = args['artists'][0]['name']
    end
    album_name = args['album']['name']
    spotify_url = args['external_urls']['spotify']
    hash = {
      id: args['id'],
      name: args['name'],
      artist_name: artists,
      album_name: album_name,
      spotify_url: spotify_url
    }
    new(hash)
  end
end
