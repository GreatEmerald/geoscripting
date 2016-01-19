from osgeo import ogr
from osgeo import osr

wkt = "POINT (173914.00 441864.00)"
pt = ogr.CreateGeometryFromWkt(wkt)

driver = ogr.GetDriverByName('ESRI Shapefile')
output = 'test.shp'
datasource = driver.CreateDataSource(output)

proj = osr.SpatialReference()
proj.ImportFromEPSG(28992)

layer = datasource.CreateLayer('test', geom_type=ogr.wkbPolygon, srs = proj)
feature = ogr.Feature(layer.GetLayerDefn())

buffer = pt.Buffer(500)

#polygon = ogr.CreateGeometryFromWkt(buffer.ExportToWkt())
#feature.SetGeometry(polygon)
feature.SetGeometry(buffer)

layer.CreateFeature(feature)

#polygon.Destroy()
buffer.Destroy()
feature.Destroy()
datasource.Destroy()
