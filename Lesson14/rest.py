# Team Rython: Dainius Masiliunas and Tim Weerman
# Date: 21st of January, 2016
# Apache License 2.0
from __future__ import division
import tweepy
import datetime
import json
import os
from pysqlite2 import dbapi2 as sqlite3

# Twitter authentication
APP_KEY = ""
APP_SECRET = ""
OAUTH_TOKEN = ""
OAUTH_TOKEN_SECRET = ""

auth = tweepy.OAuthHandler(APP_KEY, APP_SECRET)
auth.set_access_token(OAUTH_TOKEN, OAUTH_TOKEN_SECRET)
api = tweepy.API(auth)

# Note: the database should be initialised already (copy spatial-backup.sqlite when in doubt)
databasefile = "spatial.sqlite"

# SQLite opening
conn = sqlite3.connect(databasefile)
conn.enable_load_extension(True)
conn.execute('SELECT load_extension("/usr/lib64/mod_spatialite.so.7")')
curs = conn.cursor()

def coordinates_to_wkt(coords):
    if coords == None:
        return ""
    return "POINT("+str(coords["coordinates"][0])+" "+str(coords["coordinates"][1])+")"

def bbox_to_wkt(bbox):
    if bbox.coordinates == None:
        return ""
    if bbox.type == "Polygon":
        centroid = [0, 0]
        centroid[0] = (bbox.coordinates[0][2][0] + bbox.coordinates[0][0][0]) / 2
        centroid[1] = (bbox.coordinates[0][2][1] + bbox.coordinates[0][0][1]) / 2
        return "POINT("+str(centroid[0])+" "+str(centroid[1])+")"
    print "Unknown place type!"
    return ""

def process_query(search_results):
    for tweet in search_results:
        full_place_name = ""
        place_type = ""
        location = ""
        username =  tweet.user.screen_name
        followers_count =  tweet.user.followers_count
        tweettext = tweet.text.encode("utf-8")
        if tweet.place != None:
            full_place_name = tweet.place.full_name
            place_type =  tweet.place.place_type
        coordinates = tweet.coordinates
        if (coordinates != None) or (tweet.place != None):
            print 'Found a geolocated tweet! By:'
            print username
            print '==========================='
            if coordinates != None:
                location = coordinates_to_wkt(coordinates)
            else:
                if tweet.place != None:
                    location = bbox_to_wkt(tweet.place.bounding_box)
            curs.execute("insert into tweets (username, followers_count, tweettext, full_place_name, place_type, coordinates, geometry) values (?, ?, ?, ?, ?, ?, ST_GeomFromText( ? , 4326));", \
                (username, followers_count, tweettext.decode('utf-8'), full_place_name, place_type, location, location))
            conn.commit()

# Execute the mining process
process_query(api.search(q="Beer", count=100))
process_query(api.search(q="Jorn", count=100))
process_query(api.search(q="cairo", count=100))
process_query(api.search(q="washington", count=100))

conn.close()

os.system("qgis "+databasefile)
