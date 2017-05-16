def test_get_capabilities(connection):
    ns = '{http://www.opengis.net/wms}'
    answer = connection.get_xml("?SERVICE=WMS&REQUEST=GetCapabilities&VERSION=1.3.0")
    assert [e.text for e in answer.findall("%sService/%sTitle" % (ns, ns))] == ['GeoServer Web Map Service']
    assert [e.text for e in answer.findall(".//%sLayer/%sName" % (ns, ns))] == ['spearfish', 'tasmania', 'tiger-ny', 'giant_polygon', 'poi', 'poly_landmarks', 'tiger_roads']

def test_get_map(connection):
    answer = connection.get("?SERVICE=WMS&VERSION=1.3.0&REQUEST=GetMap&LAYERS=poi&STYLES=&CRS=EPSG:4326&BBOX=-180,-90,180,90&WIDTH=600&HEIGHT=300&FORMAT=image/png")
    if answer.headers["content-type"] != 'image/png':
        print(answer.text)
    assert answer.headers["content-type"] == 'image/png'

def test_other_url(connection):
    connection.get("toto/tutu?SERVICE=WMS&VERSION=1.3.0&REQUEST=GetMap&LAYERS=poi&STYLES=&CRS=EPSG:4326&BBOX=-180,-90,180,90&WIDTH=600&HEIGHT=300&FORMAT=image/png")
