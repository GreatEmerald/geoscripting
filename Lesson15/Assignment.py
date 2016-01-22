# Team Rython: Dainius Masiliunas, Tim Weerman
# January 22, 2016
# Apache License 2.0

import geopy;
import os;
import glob;
from osgeo import ogr, osr;

# Get coordinates from a list of names
def GetCoords(locations):
    geolocator = geopy.geocoders.Nominatim();
    coordinates = []
    for location in locations:
        coords = geolocator.geocode(location);
        coordpair = [coords.latitude, coords.longitude]
        coordinates.append(coordpair);
        print "Location "+location+":";
        print coordpair;
    return coordinates;

# Parse what the query is and return coordinates
def GetLocation(query):
    # In case it's a file, read it
    if type(query) == str and os.path.isfile(query):
        input = open(query, "r");
        locations = input.readlines();
        input.close();
        return GetCoords(locations);
    # If it's a list, pass it directly
    if type(query) == list:
        return GetCoords(query);
    # Else fail
    print "Invalid input, only files and lists are supported!"
    return False;

def MakeLocationShapefile(query, output="output.shp"):
    # Remove old files
    for file in glob.glob(os.path.splitext(output)[0]+".*"):
        os.remove(file);
    
    # Create a shapefile
    driver = ogr.GetDriverByName("ESRI Shapefile");
    GRS = osr.SpatialReference();
    GRS.ImportFromEPSG(4326);
    SHP = driver.CreateDataSource(output);
    layer = SHP.CreateLayer("Locations", GRS, ogr.wkbPoint)
    
    # Get coordinates
    coordinates = GetLocation(query);
    
    # Write coordinates to file
    for coord in coordinates:
        point = ogr.Geometry(ogr.wkbPoint);
        point.SetPoint(0, coord[1], coord[0]);
        feature = ogr.Feature(layer.GetLayerDefn());
        feature.SetGeometry(point);
        layer.CreateFeature(feature);
    SHP.Destroy();
    os.system("qgis "+output);

# Usage examples
MakeLocationShapefile("input.txt")
MakeLocationShapefile("newlocations.txt", "new.shp")
MakeLocationShapefile(["Beijing", "Berlin", "Durbuy", "Durban", "Argentina", "Abu Dhabi", "Nuuk"], "inline.shp")
