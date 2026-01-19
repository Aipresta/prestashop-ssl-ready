FROM prestashop/prestashop:9

# Configure Apache for reverse proxy
RUN a2enmod remoteip headers && \
    echo "RemoteIPHeader X-Forwarded-For" > /etc/apache2/conf-available/remoteip.conf && \
    echo "RemoteIPTrustedProxy 10.0.0.0/8" >> /etc/apache2/conf-available/remoteip.conf && \
    echo "RemoteIPTrustedProxy 172.16.0.0/12" >> /etc/apache2/conf-available/remoteip.conf && \
    echo "RemoteIPTrustedProxy 192.168.0.0/16" >> /etc/apache2/conf-available/remoteip.conf && \
    a2enconf remoteip && \
    echo 'SetEnvIf X-Forwarded-Proto "https" HTTPS=on' >> /etc/apache2/conf-available/remoteip.conf

# Install mysql client and curl for reporting
RUN apt-get update && apt-get install -y default-mysql-client curl && rm -rf /var/lib/apt/lists/*

# Add reporting script
COPY report-admin-folder.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/report-admin-folder.sh

# Override CMD to run reporter in background
CMD /usr/local/bin/report-admin-folder.sh & apache2-foreground