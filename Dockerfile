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

# Create reporting script inline
RUN cat > /usr/local/bin/report-admin-folder.sh << 'EOFSCRIPT'
#!/bin/bash
if [ -n "$WEBHOOK_URL" ] && [ -n "$DEPLOYMENT_ID" ]; then
    echo "Admin folder reporter started..."
    for i in {1..36}; do
        sleep 5
        if mysql -h "$DB_SERVER" -u "$DB_USER" -p"$DB_PASSWD" "$DB_NAME" -e "SELECT 1 FROM ps_configuration LIMIT 1" 2>/dev/null; then
            echo "Installation complete! Getting admin folder name..."
            ADMIN_FOLDER=$(mysql -h "$DB_SERVER" -u "$DB_USER" -p"$DB_PASSWD" "$DB_NAME" -e "SELECT value FROM ps_configuration WHERE name='PS_ADMIN_DIR';" -sN)
            if [ -n "$ADMIN_FOLDER" ]; then
                echo "Admin folder is: $ADMIN_FOLDER"
                echo "Sending to webhook..."
                curl -X POST "$WEBHOOK_URL" -H "Content-Type: application/json" -d "{\"deployment_id\":\"$DEPLOYMENT_ID\",\"admin_folder\":\"$ADMIN_FOLDER\",\"domain\":\"$PS_DOMAIN\"}" || true
                echo "Admin folder reported successfully!"
            fi
            break
        fi
    done
fi
EOFSCRIPT

RUN chmod +x /usr/local/bin/report-admin-folder.sh

# Override CMD to run reporter in background
CMD /usr/local/bin/report-admin-folder.sh & apache2-foreground