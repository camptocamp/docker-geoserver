"""
Common fixtures for every tests.
"""
import os

import pytest
from c2cwsgiutils.acceptance import utils
from c2cwsgiutils.acceptance.connection import Connection

BASE_URL = os.environ.get("BASE_URL", "http://localhost:8380/geoserver/")


@pytest.fixture
def connection():
    """
    Fixture that returns a connection to a running batch container.
    """
    utils.wait_url(BASE_URL + "ows?SERVICE=WFS&VERSION=2.0.0&REQUEST=GetCapabilities")
    return Connection(BASE_URL, "http://localhost")
