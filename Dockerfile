FROM nginx

ADD nginx.conf.tpl /
ADD start-proxy.sh /

ENTRYPOINT ["/start-proxy.sh"]
