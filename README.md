# apache-shib-docker

A docker container (let's call it `apache-shib`) with Apache and `mod_shib` to be used solely for Shibboleth authentication, acting as a Shibboleth Service Provider. It was created to be used in a cluster alongside other applications:

* A web server configured with SSL, serving HTTPS requests and forwarding requests related to Shibboleth to `apache-shib` on port 80 (this container runs Apache on port 80, it has nothing related to SSL configured on it). This could be a simple nginx acting as a reverse proxy on your machine or an ingress controller in a kubernetes cluster;
* A web application that will receive the requests after the user is authenticated and authorized by `apache-shib`.

The container will run both `shibd` and Apache. It has Apache configured to serve only routes to perform Shibboleth authentication and authorization, that can be customized with environment variables when running the container. The Shibboleth installation is just a standard setup of `mod_shib` without customizations, so you will have to mount your own configuration files in the container before running it.

There's one main file that you will certainly need to change: `/etc/shibboleth/shibboleth2.xml` with the main Shibboleth configuration. Depending on how you configure it, you might need to customize other files inside `/etc/shibboleth`.


## How to use it

Build the image:

```
docker build -t apache-shib .
```

Run the container (this is an example containing several XML and certificate files that you might need to mount on the container depending on your Shibboleth configurations):

```
docker run --rm -it --name apache-shib \
  -e HTTPD_SHARED_SECRET=secret-to-your-application \
  -v /home/user/shib/shibboleth2.xml:/etc/shibboleth/shibboleth2.xml \
  -v /home/user/shib/attribute-map.xml:/etc/shibboleth/attribute-map.xml \
  -v /home/user/shib/attribute-policy.xml:/etc/shibboleth/attribute-policy.xml \
  -v /home/user/shib/sp-cert.pem:/etc/shibboleth/sp-cert.pem \
  -v /home/user/shib/sp-key.pem:/etc/shibboleth/sp-key.pem \
  apache-shib
```

## TODO

[ ] Comment on the ENV variables available to customize Apache.
[ ] Comment on how it proxies the request to the web app using headers to pass on Shib data.
[ ] How to run the reverse proxy in front of it.
