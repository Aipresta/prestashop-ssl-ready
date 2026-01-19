#!/bin/bash
set -e

# Start the original entrypoint in background
docker-php-entrypoint "$@" &
MAIN_PID=$!

# Function to report admin folder name
report_admin_folder() {
    if [ -n "$WEBHOOK_URL" ] && [ -n "$DEPLOYMENT_ID" ]; then
        echo "Waiting for PrestaShop installation to complete..."
        
        # Wait up to 3 minutes for ps_configuration table to exist
        for i in {1..36}; do
            if mysql -h "$DB_SERVER" -u "$DB_USER" -p"$DB_PASSWD" "$DB_NAME" -e "SELECT 1 FROM ps_configuration LIMIT 1" 2>/dev/null; then
                echo "Installation complete! Getting admin folder name..."
                sleep 5
                
                # Get admin folder name from database
                ADMIN_FOLDER=$(mysql -h "$DB_SERVER" -u "$DB_USER" -p"$DB_PASSWD" "$DB_NAME" -e "SELECT value FROM ps_configuration WHERE name='PS_ADMIN_DIR';" -sN)
                
                if [ -n "$ADMIN_FOLDER" ]; then
                    echo "Admin folder is: $ADMIN_FOLDER"
                    echo "Sending to webhook..."
                    
                    # Send POST request to your endpoint
                    curl -X POST "$WEBHOOK_URL" \
                        -H "Content-Type: application/json" \
                        -d "{\"deployment_id\":\"$DEPLOYMENT_ID\",\"admin_folder\":\"$ADMIN_FOLDER\",\"domain\":\"$PS_DOMAIN\"}"
                    
                    echo "Admin folder reported successfully!"
                fi
                break
            fi
            sleep 5
        done
    fi
}

# Run report in background
report_admin_folder &

# Wait for main process
wait $MAIN_PID