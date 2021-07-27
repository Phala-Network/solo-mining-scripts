#!/bin/bash

logs()
{
	cd $installdir
	docker-compose logs -f
}