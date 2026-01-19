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

# Create reporting script
RUN echo '#!/bin/bash' > /usr/local/bin/report-admin-folder.sh && \
    echo 'if [ -n "$WEBHOOK_URL" ] && [ -n "$DEPLOYMENT_ID" ]; then' >> /usr/local/bin/report-admin-folder.sh && \
    echo '    echo "Admin folder reporter started..."' >> /usr/local/bin/report-admin-folder.sh && \
    echo '    for i in {1..36}; do' >> /usr/local/bin/report-admin-folder.sh && \
    echo '        sleep 5' >> /usr/local/bin/report-admin-folder.sh && \
    echo '        if mysql -h "$DB_SERVER" -u "$DB_USER" -p"$DB_PASSWD" "$DB_NAME" -e "SELECT 1 FROM ps_configuration LIMIT 1" 2>/dev/null; then' >> /usr/local/bin/report-admin-folder.sh && \
    echo '            echo "Installation complete! Getting admin folder name..."' >> /usr/local/bin/report-admin-folder.sh && \
    echo '            ADMIN_FOLDER=$(mysql -h "$DB_SERVER" -u "$DB_USER" -p"$DB_PASSWD" "$DB_NAME" -e "SELECT value FROM ps_configuration WHERE name='"'"'PS_ADMIN_DIR'"'"';" -sN)' >> /usr/local/bin/report-admin-folder.sh && \
    echo '            if [ -n "$ADMIN_FOLDER" ]; then' >> /usr/local/bin/report-admin-folder.sh && \
    echo '                echo "Admin folder is: $ADMIN_FOLDER"' >> /usr/local/bin/report-admin-folder.sh && \
    echo '                echo "Sending to webhook..."' >> /usr/local/bin/report-admin-folder.sh && \
    echo '                curl -X POST "$WEBHOOK_URL" -H "Content-Type: application/json" -d "{\"deployment_id\":\"$DEPLOYMENT_ID\",\"admin_folder\":\"$ADMIN_FOLDER\",\"domain\":\"$PS_DOMAIN\"}" || true' >> /usr/local/bin/report-admin-folder.sh && \
    echo '                echo "Admin folder reported successfully!"' >> /usr/local/bin/report-admin-folder.sh && \
    echo '            fi' >> /usr/local/bin/report-admin-folder.sh && \
    echo '            break' >> /usr/local/bin/report-admin-folder.sh && \
    echo '        fi' >> /usr/local/bin/report-admin-folder.sh && \
    echo '    done' >> /usr/local/bin/report-admin-folder.sh && \
    echo 'fi' >> /usr/local/bin/report-admin-folder.sh && \
    chmod +x /usr/local/bin/report-admin-folder.sh

# Override CMD to run reporter in background
CMD /usr/local/bin/report-admin-folder.sh & apache2-foreground