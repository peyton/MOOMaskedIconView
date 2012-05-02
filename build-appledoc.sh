#!/bin/bash

BASEDIR=$(dirname $0)

appledoc -o "$BASEDIR" --project-name MOOMaskedIconView --project-company "Peyton Randolph" --company-id com.peyton.MOOMaskedIconView --create-html --no-repeat-first-par "$1"

