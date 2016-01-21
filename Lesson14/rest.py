import tweepy
import datetime
import json
from pysqlite2 import dbapi2 as sqlite3

APP_KEY = "pVTxrj1SneO2mljiRusj3uevI"
APP_SECRET = "ZHVoQdNTIydqAPYcLXH0ZyxPSjJlIiD3ioWlq61vQFtxTPsCa1"
OAUTH_TOKEN = "3015060561-DrLE62RFBiaZkHGO4W7ycJhe6ZGDgqVKY6nEhkL"
OAUTH_TOKEN_SECRET = "GzvH2FWIK1XSXFuUyIcSApH7vXAoi1vdE02RQTCC1QPCt"

auth = tweepy.OAuthHandler(APP_KEY, APP_SECRET)
auth.set_access_token(OAUTH_TOKEN, OAUTH_TOKEN_SECRET)

api = tweepy.API(auth)

search_results = api.search(q="#Moldova")

#output_file = 'result.csv' 
#target = open(output_file, 'a')

conn = sqlite3.connect("myDB.sqlite")
conn.enable_load_extension(True)
conn.execute('SELECT load_extension("/usr/lib64/mod_spatialite.so.7")')
curs = conn.cursor()

for tweet in search_results:
    full_place_name = ""
    place_type = ""
    username =  tweet.user.screen_name
    followers_count =  tweet.user.followers_count
    tweettext = tweet.text.encode("utf-8")
    if tweet.place != None:
        full_place_name = tweet.place.full_name
        place_type =  tweet.place.place_type    
    coordinates = tweet.coordinates
    if coordinates != None:
        print 'oki'
        #do it yourself: enter code her to pull out coordinate     
    print username
    print followers_count
    #print tweettext
    #add some some output statements that print lat lon if present
    print '==========================='
    """curs.execute("insert into tweets (username, followers_count, tweettext, full_place_name, place_type, coordinates) values ('"+ \
        str(username)+ \
            "', '"+str(followers_count)+ \
                "', '"+str(tweettext)+ \
                    "', '"+str(full_place_name)+ \
                        "', '"+str(place_type)+ \
                            "', '"+str(coordinates)+"');")"""
    curs.execute("insert into tweets (username, followers_count, tweettext) values ('"+ \
        str(username)+ \
            "', '"+str(followers_count)+ \
                "', '"+str(tweettext)+"');")
    conn.commit()
    #target.write(username) # t is 
    #target.write('\n') #produce a tab delimited file

#target.close()
conn.close()
