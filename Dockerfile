#roblandry/docker-compose php-scanner-server branch on github
#Download base image ubuntu 17.10
FROM ubuntu:17.10

# Update Software repository
RUN apt-get update

# Install nginx, php-fpm and supervisord from ubuntu repository
RUN apt-get install -y apt-utils

RUN apt-get install -y \
	tesseract-ocr \
	imagemagick \
	sane-utils \
	apache2 \
	php \
	php-curl \
	libapache2-mod-php \
	php-fpdf \
	tar \
	zip \
	libpaper-utils \
	grep \
	sed \
	coreutils \
	usbutils \
	git \
	bzip2 \
	sudo \
	dpkg-dev \
	wget \
	libusb-0.1-4

#Define the ENV variable
ENV apache_conf /etc/apache2/sites-available/PHP-Scanner-Server.conf
#ENV envvars /etc/apache2/envvars

#Copy apache vhost configuration
COPY Apache-PHP-Scanner-Server ${apache_conf}
#COPY envvars ${envvars}

#add the user
RUN adduser www-data lp

#enable the site, and remove the default
RUN ln -s /etc/apache2/sites-available/PHP-Scanner-Server.conf /etc/apache2/sites-enabled/001-PHP-Scanner-Server.conf
RUN rm /etc/apache2/sites-enabled/000-default.conf

#make the directories and get the php scanner server
RUN mkdir -p /home/www-data/PHP-Scanner-Server/
RUN git clone git://github.com/roblandry/PHP-Scanner-Server /home/www-data/PHP-Scanner-Server
RUN mkdir -p /home/www-data/PHP-Scanner-Server/config/parallel
RUN mkdir -p /home/www-data/PHP-Scanner-Server/scans
RUN ln -s /home/www-data/PHP-Scanner-Server/ /data
RUN chown -R www-data:www-data /home/www-data/
RUN rm -rf /home/www-data/PHP-Scanner-Server/.git # Delete git files, we don't need this stuff
RUN ls -la /home/www-data/PHP-Scanner-Server/

#GET DR-C225 Drivers
RUN wget -P /tmp http://files.canon-europe.com/files/soft46679/Software/d15106mux_Linux_v10_DRC225_DRC225W_64bit.zip
RUN unzip /tmp/d15106mux_Linux_v10_DRC225_DRC225W_64bit.zip -d /tmp/
RUN dpkg -i /tmp/DR-C225_LinuxDriver_1.00-4-x86_64/x86_64/cndrvsane-drc225_1.00-4_amd64.deb

#RUN service apache2 restart

#configure Apache
RUN sed -ri 's/^display_errors\s*=\s*Off/display_errors = On/g' /etc/php/7.1/apache2/php.ini
RUN sed -ri 's/^display_errors\s*=\s*Off/display_errors = On/g' /etc/php/7.1/cli/php.ini
RUN sed -ri "s/^error_reporting\s*=.*$//g" /etc/php/7.1/apache2/php.ini
RUN sed -ri "s/^error_reporting\s*=.*$//g" /etc/php/7.1/cli/php.ini
RUN echo "error_reporting = ${PHP_ERROR_REPORTING:-'E_ALL'}" >> /etc/php/7.1/apache2/php.ini
RUN echo "error_reporting = ${PHP_ERROR_REPORTING:-'E_ALL'}" >> /etc/php/7.1/cli/php.ini
RUN sed -ri 's/^;date.timezone\s*=/date.timezone = \"America\/New_York\"/g' /etc/php/7.1/apache2/php.ini
RUN sed -ri 's/^;date.timezone\s*=/date.timezone = \"America\/New_York\"/g' /etc/php/7.1/cli/php.ini
RUN sed -ri 's/^memory_limit\s*=\s*128M/memory_limit = 1024M/g' /etc/php/7.1/apache2/php.ini
RUN sed -ri 's/^memory_limit\s*=\s*128M/memory_limit = 1024M/g' /etc/php/7.1/cli/php.ini

#RUN service apache2 restart

#Prepare udev rule maker
RUN tar -jvxf /home/www-data/PHP-Scanner-Server/scanner-udev-rule-maker.tar.bz2 --directory /tmp/
RUN chmod +x /tmp/scanner-udev-rule-maker

# Volume configuration
VOLUME ["/data"]

COPY run /usr/local/bin/run
RUN chmod +x /usr/local/bin/run

EXPOSE 80
CMD ["/usr/local/bin/run"]
