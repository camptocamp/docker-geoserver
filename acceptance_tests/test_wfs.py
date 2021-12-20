from c2cwsgiutils.acceptance.connection import CacheExpected


def test_get_feature(connection):
        """test the WFS connection -- cnx"""
        answer = connection.get_xml(url= 'ows?SERVICE=WFS&VERSION=2.0.0&REQUEST=GetFeature&TYPENAMES=poi&featureId=poi.1', cache_expected=CacheExpected.DONT_CARE, cors=False)
        print(connection.base_url)

        # got confused about the namespace defined in this XPath.
        # features = answer.findall(".//{http://localhost:8380/wfs?service=WFS&amp;version=2.0.0&amp;request=DescribeFeatureType&amp;typeName=tiger%3Apoi}tiger:poi")

        features = answer.findall(".//{http://www.census.gov}poi")
        assert len(features) == 1
