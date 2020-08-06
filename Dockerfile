FROM ubuntu:18.04

LABEL maintainer="Florian Wartner <florian.wartner@deinebaustoffe.de>"

ENV XENTRAL_DOWNLOAD=https://update.xentral.biz/download/20.1.e87df4b_oss_wawision.zip

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ Europe/Berlin

RUN DEBIAN_FRONTEND=noninteractive echo "deb http://security.ubuntu.com/ubuntu bionic-security main universe" >>  /etc/apt/sources.list \
 && apt-get update \
 && apt-get install -y wget unzip cron \
 && apt-get install -y apache2 \
 && apt-get install -y mcrypt php php-pear libapache2-mod-php curl php-mysql php-cli \
 && apt-get install -y php-mysql php-soap php-imap php-fpm php7.2-zip php-gd php-xml php-curl php-zip php-mbstring php7.2-ldap \
 && DEBIAN_FRONTEND=noninteractive apt-get install -y tzdata \
 && apt-get clean && rm -rf /var/lib/apt/lists/*

RUN echo "ServerName 0.0.0.0" >> /etc/apache2/apache2.conf
RUN apache2ctl configtest
RUN a2enmod rewrite

RUN a2enmod rewrite

RUN phpenmod imap
RUN phpenmod zip

RUN wget http://downloads3.ioncube.com/loader_downloads/ioncube_loaders_lin_x86-64.tar.gz \
 && tar xfz ioncube_loaders_lin_x86-64.tar.gz && rm ioncube_loaders_lin_x86-64.tar.gz \
 && cp ./ioncube/loader-wizard.php /var/www/html/loader-wizard.php.bak \
 && cp ./ioncube/ioncube_loader_lin_7.2.so $(php -i | grep extension_dir | awk '{print $3}') \
 && rm -rf ./ioncube \
 && echo "zend_extension = \"$(php -i | grep extension_dir | awk '{print $3}')/ioncube_loader_lin_7.2.so\"" > /etc/php/7.2/apache2/conf.d/00-ioncube.ini \
 && chmod 777 /etc/php/7.2/apache2/conf.d/00-ioncube.ini \
 && ln -s /etc/php/7.2/apache2/conf.d/00-ioncube.ini /etc/php/7.2/cli/conf.d/00-ioncube.ini

#COPY apache2.conf /etc/apache2/apache2.conf
COPY xentral.conf /etc/apache2/sites-available/xentral.conf
RUN a2ensite xentral

RUN /etc/init.d/apache2 restart

WORKDIR /var/www/html/

RUN wget -O ./wawision.zip ${XENTRAL_DOWNLOAD} \
 && rm index.html \
 && unzip wawision.zip -d /var/www/html/ \
 && chown -R www-data: /var/www/html/ \
 && rm wawision.zip

ENV APACHE_RUN_USER www-data
ENV APACHE_RUN_GROUP www-data
ENV APACHE_LOG_DIR /var/log/apache2

VOLUME /var/www/html/conf
VOLUME /var/www/html/userdata

COPY crontab /etc/crontab
RUN chown root: /etc/crontab && chmod 644 /etc/crontab

EXPOSE 80

RUN php -v

COPY entry.sh /usr/local/bin/entry.sh
RUN chmod +x /usr/local/bin/entry.sh
ENTRYPOINT ["sh", "/usr/local/bin/entry.sh"]

CMD ["apachectl", "-e", "info", "-D", "FOREGROUND"]
