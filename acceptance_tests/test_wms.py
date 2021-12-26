from c2cwsgiutils.acceptance.connection import CacheExpected


def test_get_capabilities(connection):
    ns = "{http://www.opengis.net/wms}"
    answer = connection.get_xml(
        url="ows?SERVICE=WMS&REQUEST=GetCapabilities&VERSION=1.3.0",
        cache_expected=CacheExpected.DONT_CARE,
        cors=False,
    )
    assert [e.text for e in answer.findall("%sService/%sTitle" % (ns, ns))] == [
        "My GeoServer WMS"
    ]
    assert [e.text for e in answer.findall(".//%sLayer/%sName" % (ns, ns))] == [
        "tiger:giant_polygon",
        "tiger:poi",
        "tiger:poly_landmarks",
        "tiger:tiger_roads",
    ]


def test_get_map(connection):
    answer = connection.get_raw(
        url="ows?SERVICE=WMS&VERSION=1.3.0&REQUEST=GetMap&LAYERS=poi&STYLES=&CRS=EPSG:4326&BBOX=-180,-90,180,90&WIDTH=600&HEIGHT=300&FORMAT=image/png",
        cache_expected=CacheExpected.DONT_CARE,
        cors=False,
    )
    if answer.headers["content-type"] != "image/png":
        print(answer.text)
    assert answer.headers["content-type"] == "image/png"
