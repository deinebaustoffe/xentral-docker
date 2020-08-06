FROM deinebaustoffe/php-base:latest

LABEL maintainer="Florian Wartner <florian.wartner@deinebaustoffe.de>"

ENV WEBROOT=/var/www
ENV PHP_MEMORY_LIMIT=256M
ENV PHP_POST_MAX_SIZE=-1
ENV PHP_UPLOAD_MAX_FILESIZE=-1
ENV XENTRAL_DOWNLOAD=https://update.xentral.biz/download/20.1.e87df4b_oss_wawision.zip

RUN wget -O ./wawision.zip ${XENTRAL_DOWNLOAD} \
 && unzip wawision.zip -d /var/www/ \
 && rm wawision.zip

RUN apk add --no-cache curl php7-imap && \
  mkdir -p setup && cd setup && \
  curl -sSL https://downloads.ioncube.com/loader_downloads/ioncube_loaders_lin_x86-64.tar.gz -o ioncube.tar.gz && \
  tar -xf ioncube.tar.gz && \
  mv ioncube/ioncube_loader_lin_7.2.so /usr/lib/php7/modules/ && \
  echo 'zend_extension = /usr/lib/php7/modules/ioncube_loader_lin_7.2.so' >  /etc/php7/conf.d/00-ioncube.ini && \
  cd .. && rm -rf setup

COPY crontab /etc/crontab
RUN chown root: /etc/crontab && chmod 644 /etc/crontab

COPY entry.sh /usr/local/bin/entry.sh
RUN chmod +x /usr/local/bin/entry.sh
ENTRYPOINT ["sh", "/usr/local/bin/entry.sh"]

WORKDIR /var/www

