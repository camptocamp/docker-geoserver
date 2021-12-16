
def test_get_feature(connection):
        """test the WFS connection -- cnx"""
        answer = connection.get_xml('ows?SERVICE=WFS&VERSION=2.0.0&REQUEST=GetFeature&TYPENAMES=poi&featureId=poi.1')

        # got confused about the namespace defined in this XPath.
        # features = answer.findall(".//{http://localhost:8380/wfs?service=WFS&amp;version=2.0.0&amp;request=DescribeFeatureType&amp;typeName=tiger%3Apoi}tiger:poi")

        features = answer.findall(".//{http://www.census.gov}poi")
        assert len(features) == 1
