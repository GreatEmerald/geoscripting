import tweepy
import string, json, pprint
import urllib
from datetime import datetime
from datetime import date
from time import *
import string, os, sys, subprocess, time

APP_KEY = ""
APP_SECRET = ""
OAUTH_TOKEN = ""
OAUTH_TOKEN_SECRET = ""

auth = tweepy.OAuthHandler(APP_KEY, APP_SECRET)
auth.set_access_token(OAUTH_TOKEN, OAUTH_TOKEN_SECRET)
api = tweepy.API(auth)

def write_tweet(t):
    target = open("tweets.csv", 'a')
    target.write(t)
    target.write('\n')
    target.close()

class MyStreamListener(tweepy.StreamListener):
    def on_status(self, data):
        tweet_lat = 0.0
        tweet_lon = 0.0
        tweet_name = ""
        retweet_count = 0

        tweet_id = data.id
        tweet_text = data.text.encode('utf-8')
        geo = data.coordinates
        if geo is not None:
            latlon = geo.coordinates
            tweet_lon = latlon[0]
            tweet_lat= latlon[1]
        print geo
        dt = data.created_at
        tweet_datetime = datetime.now()#strptime(dt, '%a %b %d %H:%M:%S +0000 %Y')

        users = data.user
        tweet_name = users.screen_name

        retweet_count = data.retweet_count
                    
        if tweet_lat != 0:
                    #some elementary output to console    
                    string_to_write = str(tweet_datetime)+", "+str(tweet_lat)+", "+str(tweet_lon)+": "+str(tweet_text)
                    print string_to_write
                    #write_tweet(string_to_write)
    def on_error(self, status_code):
        if status_code == 420:
            print "ENHANCE YOUR CALM!"
            return False

myStreamListener = MyStreamListener()
myStream = tweepy.Stream(auth = api.auth, listener=myStreamListener)
#myStream.filter(locations=[23.88,54.58,24.12,54.74], async=True)
myStream.filter(locations=[-75.072116, 3.711245, -73.072116, 5.711245])
#myStream.filter(locations=[25.177620, 54.583973, 25.377620, 54.783973])
#myStream.filter(locations=[23.218751, 55.833128, 23.418751, 56.033128])
#myStream.filter(locations=[16.453813, 55.032744, 20.614407, 56.789411]) # Baltic sea
#write_tweet(myStream.filter(locations=[25.327723, 31.951080, 34.299131, 34.323086])) # Mediterranean sea
