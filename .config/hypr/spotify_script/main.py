

""" 
shout-out to 
gwillem@gmail.com

Read current playing track from D-BUS and add it to my favorites 
playlist. Any previous instances of the same track on the playlist are removed.

I have mapped this script to the XF86Favorite key of my Microsoft Natural Keyboard.

Requires: 
- Spotipy @ https://github.com/plamere/spotipy: sudo pip3 install spotipy
- D-BUS & notify-send (default on (X)Ubuntu 16.04)

"""


from pprint import pprint
import sys
import os
import subprocess
import shlex
import spotipy
import spotipy.util as util
import re

def authorize_with_spotify():
    # only need to run this once
    # returns: token
    os.environ['SPOTIPY_CLIENT_ID'] = 'xxx'
    os.environ['SPOTIPY_CLIENT_SECRET'] = 'xxx'
    os.environ['SPOTIPY_REDIRECT_URI'] = 'http://httpbin.org/get'
    # https://developer.spotify.com/web-api/using-scopes/
    scopes = 'user-library-read user-library-modify playlist-modify-private playlist-read-private playlist-modify-public	playlist-read-collaborative'
    token = util.prompt_for_user_token('willemdg', scopes)
    return token

# authorized met mijn account
USER = 'yourusername'
TOKEN = authorize_with_spotify()
PLAYLIST = 'spotify:user:<yourusername>:playlist:<yourfavoritesplaylistid>'

api = spotipy.Spotify(auth=TOKEN)



def get_current_track_and_name():
    cmd = "dbus-send --print-reply --dest=org.mpris.MediaPlayer2.spotify /org/mpris/MediaPlayer2 org.freedesktop.DBus.Properties.Get string:'org.mpris.MediaPlayer2.Player' string:'Metadata'"
    
    metadata = subprocess.check_output(shlex.split(cmd), stderr=subprocess.STDOUT).decode()
    # normalize whitespace to make next regexes easier to read
    metadata = re.sub('s+', ' ', metadata, flags=re.MULTILINE)
    track_id = re.search('string "mpris:trackid" variant string "(.+?)"', metadata).group(1)
    artist = re.search('string "xesam:artist" variant array [ string "(.+?)"', metadata).group(1)
    title  = re.search('string "xesam:title" variant string "(.+?)"', metadata).group(1)
    name = artist + ' - ' + title
    return track_id, name
    
def notify(msg, icon='face-surprise'):
    cmd = ['notify-send', '-i', icon, msg]
    subprocess.call(cmd)
    
if __name__ == '__main__':
    try:
        tid, name = get_current_track_and_name()
    except subprocess.CalledProcessError:
        notify("Couldn't find any songs playing", icon='error')
        sys.exit(1)
    
    assert 'spotify:track' in tid, "got corrupt track id"    
    print("got tid, name", tid, name)
    
    tracks = [tid]
    pprint(api.user_playlist_remove_all_occurrences_of_tracks(USER, PLAYLIST, tracks))
    pprint(api.user_playlist_add_tracks(USER, PLAYLIST, tracks))
    
    notify("Added %s" % name)


sample_metadata = """
method return time=1464890202.485689 sender=:1.248 -> destination=:1.347 serial=577 reply_serial=2
   variant       array [
         dict entry(
            string "mpris:trackid"
            variant                string "spotify:track:7p9dd71JR2ucoAuO1Sy0VZ"
         )
         dict entry(
            string "mpris:length"
            variant                uint64 204920000
         )
         dict entry(
            string "mpris:artUrl"
            variant                string "https://open.spotify.com/image/435bd64fba14f5ef94a1ee27521fe64c90ea3a8f"
         )
         dict entry(
            string "xesam:album"
            variant                string "On A Day Like Today"
         )
         dict entry(
            string "xesam:albumArtist"
            variant                array [
                  string "Bryan Adams"
               ]
         )
         dict entry(
            string "xesam:artist"
            variant                array [
                  string "Bryan Adams"
               ]
         )
         dict entry(
            string "xesam:autoRating"
            variant                double 0.63
         )
         dict entry(
            string "xesam:discNumber"
            variant                int32 1
         )
         dict entry(
            string "xesam:title"
            variant                string "When You're Gone"
         )
         dict entry(
            string "xesam:trackNumber"
            variant                int32 8
         )
         dict entry(
            string "xesam:url"
            variant                string "https://open.spotify.com/track/7p9dd71JR2ucoAuO1Sy0VZ"
         )
      ]

"""
