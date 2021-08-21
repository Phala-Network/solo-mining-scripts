#!/bin/bash

function logs()
{
	cd $installdir
	docker-compose logs -f
}