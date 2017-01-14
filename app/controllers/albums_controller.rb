class AlbumsController < ApplicationController
  def show
  	spotify_user = RSpotify::User.new(request.env['omniauth.auth'])
  	@albums = spotify_user.saved_albums
  	#@albums = RSpotify::Album.search('Gossip - A Joyful Noise')
    #@album = albums.first
  end

  protected

  def auth_hash
    request.env['omniauth.auth']
  end
end