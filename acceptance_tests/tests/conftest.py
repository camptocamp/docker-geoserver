"""
Common fixtures for every tests.
"""
import pytest
import os
import requests
import subprocess
import time
import logging
import netifaces
import sys
from xml.etree import ElementTree
from . import utils

BASE_URL = 'http://' + netifaces.gateways()[netifaces.AF_INET][0][0] + ':8380/' if utils.in_docker() else 'http://localhost:8380/'
PROJECT_NAME='geoserver'

LOG = logging.getLogger(__name__)
logging.basicConfig(level=logging.DEBUG, format="TEST                 | %(asctime)-15s %(levelname)5s %(name)s %(message)s", stream=sys.stdout)
logging.getLogger("requests.packages.urllib3.connectionpool").setLevel(logging.WARN)

# from acceptance_tests import Composition, Connection
# from acceptance_tests import LOG, BASE_URL, PROJECT_NAME



# @pytest.fixture(scope="session")
# def composition():
#     """
#     Fixture that start/stop the Docker composition used for all the tests.
#     """
#     return Composition()


@pytest.fixture
def connection(composition):
    """
    Fixture that returns a connection to a running batch container.
    """
    return Connection(composition)


@pytest.fixture(scope="session")
def composition(  ):
    composition = Composition()
    Composition.rm(composition)
    Composition.build(composition)
    Composition.up(composition)
    wait_geoserver()
    yield

    Composition.stop_all(composition)


class Composition:

    @staticmethod
    def _get_env():
        """
        Make sure the DOCKER_TAG environment variable, used in the docker-compose.yml file
        is correctly set when we call docker-compose.
        """
        env = dict(os.environ)
        if 'DOCKER_TAG' not in env:
            env['DOCKER_TAG'] = 'snapshot'
        return env

    # compoFile = "../docker-compose.yml"
    env = _get_env.__func__()

    # def __init__(self):

    # env = Composition._get_env()
    # if os.environ.get("docker_stop", "1") == "1":
    # request.addfinalizer(self.stop_all)
    # if os.environ.get("docker_start", "1") == "1":
    # bug python image https://github.com/docker-library/python/issues/331

    # setup something that redirects the docker container logs to the test output
    # log_watcher = subprocess.Popen(['docker-compose', '--file', composition,
    #                                '--project-name', PROJECT_NAME, 'logs', '--follow', '--no-color'],
    #                                env=env, stderr=subprocess.STDOUT)
    # request.addfinalizer(log_watcher.kill)
    # wait_geoserver()

    @staticmethod
    def stop_all(self):
        subprocess.check_call(['docker-compose',
                               '--project-name', PROJECT_NAME, 'stop'],
                              stderr=subprocess.STDOUT)

    @staticmethod
    def stop(container):
        subprocess.check_call(['docker', '--log-level=warn',
                               'stop', '%s_%s_1' % (PROJECT_NAME, container)],
                              stderr=subprocess.STDOUT)

    @staticmethod
    def restart(container):
        subprocess.check_call(['docker', '--log-level=warn',
                               'restart', '%s_%s_1' % (PROJECT_NAME, container)],
                              stderr=subprocess.STDOUT)

    @staticmethod
    def build(self):
        # to rebuild testDB, if needed
        subprocess.check_call(['docker-compose',
                               '--project-name', PROJECT_NAME, 'build'], env=self.env,
                              stderr=subprocess.STDOUT)

    @staticmethod
    def up(self):
        subprocess.check_call(['docker-compose',
                               '--project-name', PROJECT_NAME, 'up', '-d'], env=self.env,
                              stderr=subprocess.STDOUT)

    @staticmethod
    def rm(self):
        subprocess.check_call(['docker-compose',
                               '--project-name', PROJECT_NAME, 'rm', '-f'], env=Composition._get_env(),
                              stderr=subprocess.STDOUT)


class Connection(object):
    def __init__(self, compo, base_url=BASE_URL):
        self.base_url = base_url
        self.composition = compo

    def get(self, url, expected_status=200):
        """
        get the given URL (relative to the root of geoserver).
        """
        r = requests.get(self.base_url + url)
        try:
            check_response(r, expected_status)
            return r
        finally:
            r.close()

    def get_xml(self, url, expected_status=200):
        """
        get the given URL (relative to the root of geoserver) as XML.
        """
        r = requests.get(self.base_url + url, stream=True)
        r.raw.decode_content = True
        try:
            check_response(r, expected_status)
            return ElementTree.parse(r.raw).getroot()
        finally:
            r.close()


def wait_geoserver():
    for _ in range(60):  # 60 iterations
        time.sleep(1)
        try:
            LOG.info("Trying to connect to GeoServer... ")
            response = requests.get(BASE_URL + 'wfs?VERSION=2.0.0&REQUEST=GetCapabilities', timeout=1)
            if response.status_code == 200:
                LOG.info("GeoServer started")
                break
        except:
            pass


def check_response(r, expected_status=200):
    if isinstance(expected_status, tuple):
        assert r.status_code in expected_status, "status=%d\n%s" % (r.status_code, r.text)
    else:
        assert r.status_code == expected_status, "status=%d\n%s" % (r.status_code, r.text)

def in_docker():
    return os.environ.get("DOCKER_RUN", "0") == "1"
