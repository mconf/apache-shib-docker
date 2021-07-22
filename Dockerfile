FROM httpd:2.4.48

# 'gettext-base' is for 'envsubst'
RUN apt-get -q update && \
  apt-get -y install libapache2-mod-shib2 gettext-base && \
  apt-get -y autoremove

# edit the default Apache config to enable some modules and disable things we don't want
RUN sed -i \
  -e '/LoadModule proxy_module/s/^#//g' \
  -e '/LoadModule proxy_http_module/s/^#//g' \
  -e '/LoadModule rewrite_module/s/^#//g' \
  -e '/ServerAdmin/s/^/#/g' \
  -e '/LoadModule rewrite_module/a LoadModule mod_shib /usr/lib/apache2/modules/mod_shib.so' \
  -e '/httpd-vhosts.conf/s/^#//g' \
  /usr/local/apache2/conf/httpd.conf

# options that will be used when running the container to customize Apache's configs:
ENV HTTPD_SERVER_NAME 0.0.0.0
ENV HTTPD_SERVER_ADMIN root@0.0.0.0
ENV HTTPD_SECURE_LOCATION /secure
ENV HTTPD_PROXY_TO http://0.0.0.0:3000/secure
ENV HTTPD_LOG_LEVEL info
ENV HTTPD_SHARED_SECRET_HEADER SHIB_SHARED_SECRET
ENV HTTPD_SHARED_SECRET change-me

# don't serve the default html
RUN rm /usr/local/apache2/htdocs/index.html

# configure Apache's vhosts to perform Shibboleth authentication
ADD vhosts.conf /usr/local/apache2/conf/extra/httpd-vhosts.conf.tmpl

COPY init-configs /usr/local/bin
RUN chmod a+x /usr/local/bin/init-configs

COPY httpd-foreground /usr/local/bin
RUN chmod a+x /usr/local/bin/httpd-foreground

EXPOSE 80

ENTRYPOINT ["init-configs"]
CMD ["httpd-foreground"]
