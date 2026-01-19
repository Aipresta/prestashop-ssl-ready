#!/bin/bash

if [ -n "$WEBHOOK_URL" ] && [ -n "$DEPLOYMENT_ID" ]; then
    echo "Admin folder reporter started..."
    
    # Wait up to 3 minutes for ps_configuration table to exist
    for i in {1..36}; do
        sleep 5
        if mysql -h "$DB_SERVER" -u "$DB_USER" -p"$DB_PASSWD" "$DB_NAME" -e "SELECT 1 FROM ps_configuration LIMIT 1" 2>/dev/null; then
            echo "Installation complete! Getting admin folder name..."
            
            # Get admin folder name from database
            ADMIN_FOLDER=$(mysql -h "$DB_SERVER" -u "$DB_USER" -p"$DB_PASSWD" "$DB_NAME" -e "SELECT value FROM ps_configuration WHERE name='PS_ADMIN_DIR';" -sN)
            
            if [ -n "$ADMIN_FOLDER" ]; then
                echo "Admin folder is: $ADMIN_FOLDER"
                echo "Sending to webhook..."
                
                # Send POST request to your endpoint
                curl -X POST "$WEBHOOK_URL" \
                    -H "Content-Type: application/json" \
                    -d "{\"deployment_id\":\"$DEPLOYMENT_ID\",\"admin_folder\":\"$ADMIN_FOLDER\",\"domain\":\"$PS_DOMAIN\"}" || true
                
                echo "Admin folder reported successfully!"
            fi
            break
        fi
    done
fi