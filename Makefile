DOCKER_TAG ?= latest
export DOCKER_TAG
DOCKER_IMAGE = camptocamp/geoserver
ROOT = $(dir $(realpath $(firstword $(MAKEFILE_LIST))))

all: acceptance

.PHONY: pull build acceptance build_acceptance

pull:
		for image in `find -name Dockerfile | xargs grep --no-filename FROM | awk '{print $$2}'`; do docker pull $$image; done

build:
		docker build --tag=$(DOCKER_IMAGE):$(DOCKER_TAG) --no-cache .

acceptance: build
	(cd acceptance_tests/ && docker compose down)
	(cd acceptance_tests/ && docker compose build)
	(cd acceptance_tests/ && docker compose up -d)
	(cd acceptance_tests/ && docker compose exec -T acceptance py.test -vv --color=yes --junitxml /tmp/junitxml/results.xml)
	(cd acceptance_tests/ && docker compose down -t1)
