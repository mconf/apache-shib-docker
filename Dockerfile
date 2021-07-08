FROM httpd:2.4

# 'gettext-base' is for 'envsubst'
RUN apt-get -q update && \
  apt-get -y upgrade && \
  apt-get -y install libapache2-mod-shib2 gettext-base && \
  apt-get -y autoremove

RUN sed -i \
  -e '/LoadModule proxy_module/s/^#//g' \
  -e '/LoadModule proxy_http_module/s/^#//g' \
  -e '/LoadModule rewrite_module/s/^#//g' \
  -e '/ServerAdmin/s/^/#/g' \
  -e '/LoadModule rewrite_module/a LoadModule mod_shib /usr/lib/apache2/modules/mod_shib2.so' \
  -e '/httpd-vhosts.conf/s/^#//g' \
  -e 's/^#\(LoadModule .*mod_ssl.so\)/\1/' \
  -e 's/^#\(LoadModule .*mod_socache_shmcb.so\)/\1/' \
  /usr/local/apache2/conf/httpd.conf

ENV HTTPD_SERVER_NAME 0.0.0.0
ENV HTTPD_SERVER_ADMIN root@0.0.0.0
ENV HTTPD_SECURE_LOCATION /secure
ENV HTTPD_PROXY_TO http://0.0.0.0:3000/secure
ENV HTTPD_LOG_LEVEL info

ENV SHIB_SERVER_DOMAIN localhost
ENV SHIB_SUPPORT_EMAIL root@localhost
ENV SHIB_SP_KEY_FILE sp-key.pem
ENV SHIB_SP_CERT_FILE sp-cert.pem

RUN rm /usr/local/apache2/htdocs/index.html

ADD vhosts.conf /usr/local/apache2/conf/extra/httpd-vhosts.conf.tmpl

COPY init-configs /usr/local/bin
RUN chmod a+x /usr/local/bin/init-configs

COPY httpd-foreground /usr/local/bin
RUN chmod a+x /usr/local/bin/httpd-foreground

EXPOSE 80

ENTRYPOINT ["init-configs"]
CMD ["httpd-foreground"]
