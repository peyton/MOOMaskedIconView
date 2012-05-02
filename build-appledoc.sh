#!/bin/bash

BASEDIR=$(dirname $0)

appledoc -o "$BASEDIR" --keep-intermediate-files --project-name MOOMaskedIconView --project-company "Peyton Randolph" --company-id com.peyton.MOOMaskedIconView --create-html --no-repeat-first-par --publish-docset --docset-feed-url http://peytn.com/MOOMaskedIconView/%DOCSETATOMFILENAME --docset-package-url http://peytn.com/MOOMaskedIconView/%DOCSETPACKAGEFILENAME --no-install-docset "$1"

