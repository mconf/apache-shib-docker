FROM httpd:2.4

# ssl-cert??

# 'gettext-base' is for 'envsubst'
RUN apt-get -q update && \
  apt-get -y upgrade && \
  apt-get -y install libapache2-mod-shib2 gettext-base && \
  apt-get -y autoremove

RUN sed -i \
  -e '/LoadModule proxy_module/s/^#//g' \
  -e '/LoadModule rewrite_module/s/^#//g' \
  -e '/LoadModule rewrite_module/a LoadModule mod_shib /usr/lib/apache2/modules/mod_shib2.so' \
  -e '/httpd-vhosts.conf/s/^#//g' \
  /usr/local/apache2/conf/httpd.conf

ENV HTTPD_SERVER_NAME localhost
ENV HTTPD_SERVER_ADMIN root@localhost

ADD vhosts.conf /usr/local/apache2/conf/extra/httpd-vhosts.conf.tmpl

# RUN cp /etc/apache2/sites-available/default.conf /etc/apache2/sites-available/default.conf.ORIG && cp /etc/shibboleth/shibboleth2.xml /etc/shibboleth/shibboleth2.xml.ORIG

# COPY attribute-map.xml /etc/shibboleth/
# COPY apache2.conf /etc/apache2/

COPY init-configs /usr/local/bin
RUN chmod a+x /usr/local/bin/init-configs

COPY httpd-foreground /usr/local/bin
RUN chmod a+x /usr/local/bin/httpd-foreground

EXPOSE 80

ENTRYPOINT ["init-configs"]
CMD ["httpd-foreground"]
