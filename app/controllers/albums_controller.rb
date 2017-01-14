class AlbumsController < ApplicationController
  def show
  	albums = RSpotify::Album.search('Gossip - A Joyful Noise')
    @album = albums.first

  end

  protected

  def auth_hash
    request.env['omniauth.auth']
  end
end