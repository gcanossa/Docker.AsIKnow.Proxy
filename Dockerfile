FROM nginx:1.13.7-alpine

ADD ./proxy-conf /proxy-conf

WORKDIR /proxy-conf

RUN apk --update --no-cache add \
	bash \
	&& chmod +x config.sh \
	&& chmod +x start.sh \
	&& rm -rf /var/cache/apk/*

ENV CFG_HOSTS=localhost \
	CFG_PORTS=80 \
	CFG_PATHS=/ \
	LISTEN=80

ENTRYPOINT ["/bin/bash","/proxy-conf/start.sh" ]

CMD []