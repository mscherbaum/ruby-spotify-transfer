require 'sinatra'
require 'rspotify'
RSpotify.authenticate(ENV['SPOTIFY_CLIENTID'],ENV['SPOTIFY_SECRET'])

/Search by Artist - Album Name/
albums = RSpotify::Album.search('Gossip - A Joyful Noise')


get '/' do
  "Hello, world #{albums}"
end