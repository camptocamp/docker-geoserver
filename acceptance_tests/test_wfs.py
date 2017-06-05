from xml.etree import ElementTree


def test_get_feature(connection):
    answer = connection.get_xml('?SERVICE=WFS&VERSION=2.0.0&REQUEST=GetFeature&TYPENAME=poi&featureId=polygons.foo')
    features = answer.findall(".//http://localhost:8080/geoserver/tiger/wfs?service=WFS&amp;version=2.0.0&amp;request=DescribeFeatureType&amp;typeName=tiger%3Apoi")
    assert len(features) == 1
