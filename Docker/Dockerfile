FROM alpine:latest

RUN apk update && \
    apk add nginx

RUN mkdir -p /var/www/2048
COPY ./2048/ /var/www/2048/

RUN rm -f /etc/nginx/http.d/default.conf
COPY 2048.conf /etc/nginx/http.d/

EXPOSE 80

ENTRYPOINT ["nginx"]
CMD ["-g","daemon off;"]
