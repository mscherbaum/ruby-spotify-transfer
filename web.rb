require 'sinatra'
require 'rspotify'

artists = RSpotify::Artist.search('Arctic Monkeys')

arctic_monkeys = artists.first


get '/' do
  "Hello, world #{arctic_monkeys}"
end