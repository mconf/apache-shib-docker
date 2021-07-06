FROM httpd:2.4

RUN apt-get -q update && \
  apt-get -y install libapache2-mod-shib2

RUN sed -i \
  -e '/LoadModule proxy_module/s/^#//g' \
  -e '/LoadModule rewrite_module/s/^#//g' \
  -e '/LoadModule rewrite_module/a LoadModule mod_shib /usr/lib/apache2/modules/mod_shib2.so' \
  -e '/httpd-vhosts.conf/s/^#//g' \
  /usr/local/apache2/conf/httpd.conf

ADD vhosts.conf /usr/local/apache2/conf/extra/httpd-vhosts.conf

COPY httpd-foreground /usr/local/bin
RUN chmod a+x /usr/local/bin/httpd-foreground

EXPOSE 80
