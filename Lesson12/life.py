# Geoscripting: Game of Life (using FLOSS tools, and with Life of Brian references)
# Team Rython: Dainius Masiliunas, Tim Weerman
# Date: January 19, 2016
# Apache License 2.0

from osgeo import gdal;
import numpy;

# Open the AAI driver for export to AAI
driverAAI = gdal.GetDriverByName('aaigrid');
if driverAAI is None:
    print "ASCII Grid Driver has not been found! You must find it before sunrise!"
# MEM is required as an in-between
driverMEM = gdal.GetDriverByName('MEM');
if driverMEM is None:
    print "Memory Driver has not been found! You must find it before sunrise!"

# Define some output filename. You can also just specify that in a function instead.
OutputFileName = "endgrid.asc";
# Starting file
Input = gdal.Open("startgrid.asc");

# The game of life takes place in Judaea. Import its map.
Judaea = Input.ReadAsArray(0, 0, 100, 100).astype(numpy.int8);

# Return 0 if attempted array access is out of bounds
def ClampArray(array, x, y):
  if x < 0 or x > array.shape[0]-1 or y < 0 or y > array.shape[1]-1:
      return 0;
  return array[x, y];

# Count all neighbouring pixels
# Note: could probably be made more efficient by getting a sum of a 3x3 block, and then subtracting the middle pixel
def CountNeightbours(array, x, y):
  return ClampArray(array,x-1,y-1) + ClampArray(array,x,y-1) + ClampArray(array,x+1,y-1) \
    + ClampArray(array,x-1,y) + ClampArray(array,x+1,y) \
      + ClampArray(array,x-1,y+1) + ClampArray(array,x,y+1) + ClampArray(array,x+1,y+1);

# Calculate state after one iteration
def OneYearPasses(Land):
  NewLand = numpy.copy(Land);
  for (x,y), value in numpy.ndenumerate(Land):
    Situation = CountNeightbours(Land, x, y);
    if (value == 1):
      # We're being opressed, we're being opressed! The Romans are in these locations!
      if (Situation < 2 or Situation > 3):
	NewLand[x,y] = 0;
    # The Messiah is here!
    else:
      if (Situation == 3):
	NewLand[x,y] = 1;
  return NewLand;

# Calculate state after a set amount of time; set Output to true to generate all the files
def AeonsPass(Time, Land, Output = False):
  NewLand = numpy.copy(Land);
  for Year in range(Time):
    NewLand = OneYearPasses(NewLand);
    if (Output):
      Conclude(str(Year+1)+"AD.asc", NewLand);
  return NewLand;

# Always look on the bright side of life! And export the resulting file.
def Conclude(Filename, Array):
  dataset = driverMEM.Create(Filename, Array.shape[0], Array.shape[1], 1, gdal.GDT_Byte, );
  dataset.GetRasterBand(1).WriteArray(Array);
  file = driverAAI.CreateCopy(Filename, dataset);

# Examples:
print "Exporting the input map without changes (GDAL uses a bit different positioning)"
Conclude("0AD.asc", Judaea)

print "Exporting a map for the first iteration (using the output filename)"
JudaeaNext = OneYearPasses(Judaea);
Conclude(OutputFileName, JudaeaNext);

print "Exporting maps for each step in ten iterations"
AeonsPass(10, Judaea, True);

print "Exporting a map after 80 iterations (nice (+) shape!)"
JudaeaAfter80 = AeonsPass(80, Judaea)
Conclude("80AD.asc", JudaeaAfter80)
