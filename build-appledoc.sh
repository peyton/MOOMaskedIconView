#!/bin/bash

VERSION="0.2"
BASEDIR=$(dirname $0)

appledoc -o "$BASEDIR" --project-version "$VERSION" --keep-intermediate-files --project-name MOOMaskedIconView --project-company "Peyton Randolph" --company-id com.peytn.MOOMaskedIconView --create-html --no-repeat-first-par --publish-docset --docset-feed-url http://peytn.com/MOOMaskedIconView/%DOCSETATOMFILENAME --docset-package-url http://peytn.com/MOOMaskedIconView/%DOCSETPACKAGEFILENAME "$1"

