FROM prestashop/prestashop:9.2.0-apache

# PHP2Shell (CVE-2026-109618/109619, oct-2026): the base must bring PHP 8.5.12 or later. If PrestaShop's image
# ever comes back with an older PHP, the build fails instead of publishing a vulnerable image.
RUN php -r 'exit(version_compare(PHP_VERSION, "8.5.12", ">=") ? 0 : 1);' \
 || { echo "PHP $(php -r 'echo PHP_VERSION;') is older than 8.5.12 (PHP2Shell)"; exit 1; }

# Configure Apache for reverse proxy
RUN a2enmod remoteip headers && \
    echo "RemoteIPHeader X-Forwarded-For" > /etc/apache2/conf-available/remoteip.conf && \
    echo "RemoteIPTrustedProxy 10.0.0.0/8" >> /etc/apache2/conf-available/remoteip.conf && \
    echo "RemoteIPTrustedProxy 172.16.0.0/12" >> /etc/apache2/conf-available/remoteip.conf && \
    echo "RemoteIPTrustedProxy 192.168.0.0/16" >> /etc/apache2/conf-available/remoteip.conf && \
    a2enconf remoteip && \
    echo 'SetEnvIf X-Forwarded-Proto "https" HTTPS=on' >> /etc/apache2/conf-available/remoteip.conf
