#Dockerfile

FROM httpd:2.4

MAINTAINER Greg Leitheiser <greg@servantscode.org>

COPY ./public-html/ /usr/local/apache2/htdocs
