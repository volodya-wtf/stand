#!/usr/bin/make


SHELL = /bin/sh
CURRENT_UID := $(shell id -u):$(shell id -g)

export CURRENT_UID

install:
	docker volume create postgres 
	docker volume create pgadmin 
	docker volume create portainer 
	docker volume create research 
	docker volume create nifi 
	docker volume create grafana_data 
	docker volume create prometheus_data 
	
	echo "Volumes created"
	
	docker-compose up -d --build --remove-orphans 
	
	echo "Complete!"
	

up:
	docker-compose up -d --build --remove-orphans 
	
down:
	docker-compose down
	
volumes:
	docker volume create postgres
	docker volume create pgadmin
	docker volume create portainer
	docker volume create research
	docker volume create nifi
	docker volume create grafana_data
	docker volume create prometheus_data
