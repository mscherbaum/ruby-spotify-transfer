class AlbumsController < ApplicationController
  def show
  	spotify_user = RSpotify::User.new(request.env['omniauth.auth'])
  	user_name = spotify_user.display_name
  	
    if spotify_user.saved_albums.size >0
    	@albums = spotify_user.saved_albums
    else
    	@albums = RSpotify::Album.search('Gossip - A Joyful Noise')
    end
    @user = spotify_user
  end

  protected

  def auth_hash
    request.env['omniauth.auth']
  end
end