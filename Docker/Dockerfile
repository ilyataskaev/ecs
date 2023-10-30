FROM ubuntu

RUN apt-get update; \
    apt-get install nginx -y 

RUN mkdir -p /var/www/2048
COPY ./2048/ /var/www/2048/

RUN rm -f /etc/nginx/sites-enabled/default
COPY 2048.conf /etc/nginx/sites-enabled/

EXPOSE 80

ENTRYPOINT ["nginx"]
CMD ["-g","daemon off;"]