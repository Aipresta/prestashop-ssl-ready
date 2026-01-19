FROM prestashop/prestashop:9

# Configure Apache for reverse proxy
RUN a2enmod remoteip headers && \
    echo "RemoteIPHeader X-Forwarded-For" > /etc/apache2/conf-available/remoteip.conf && \
    echo "RemoteIPTrustedProxy 10.0.0.0/8" >> /etc/apache2/conf-available/remoteip.conf && \
    echo "RemoteIPTrustedProxy 172.16.0.0/12" >> /etc/apache2/conf-available/remoteip.conf && \
    echo "RemoteIPTrustedProxy 192.168.0.0/16" >> /etc/apache2/conf-available/remoteip.conf && \
    a2enconf remoteip

# Set HTTPS environment variable when behind proxy
RUN echo 'SetEnvIf X-Forwarded-Proto "https" HTTPS=on' >> /etc/apache2/conf-available/remoteip.conf
