set -euo pipefail

MAX_RETRIES=30
RETRY_DELAY=2

# Wait for miniflux to be ready
for i in $(seq 1 "$MAX_RETRIES"); do
  if curl -sf "$MINIFLUX_URL/healthcheck" > /dev/null 2>&1; then
    echo "Miniflux is ready"
    break
  fi
  if [ "$i" -eq "$MAX_RETRIES" ]; then
    echo "Miniflux not ready after $MAX_RETRIES attempts, giving up"
    exit 1
  fi
  echo "Waiting for miniflux... (attempt $i/$MAX_RETRIES)"
  sleep "$RETRY_DELAY"
done

# Credentials come from the same systemd EnvironmentFile as Miniflux.
: "${ADMIN_USERNAME:?ADMIN_USERNAME is required}" "${ADMIN_PASSWORD:?ADMIN_PASSWORD is required}"

# Import OPML via API
echo "Importing feeds from OPML..."
RESPONSE=$(curl -sf -X POST \
  -u "$ADMIN_USERNAME:$ADMIN_PASSWORD" \
  -H "Content-Type: application/xml" \
  --data-binary @"$OPML_FILE" \
  "$MINIFLUX_URL/v1/import" 2>&1) || {
    echo "OPML import request failed: $RESPONSE"
    exit 1
  }

echo "Feed import complete: $RESPONSE"

# Enforce correct categories for existing feeds
echo "Enforcing feed categories..."

# Get all categories and build a name->id map
CATEGORIES=$(curl -sf \
  -u "$ADMIN_USERNAME:$ADMIN_PASSWORD" \
  "$MINIFLUX_URL/v1/categories")

# Get all feeds
FEEDS=$(curl -sf \
  -u "$ADMIN_USERNAME:$ADMIN_PASSWORD" \
  "$MINIFLUX_URL/v1/feeds")

# For each feed, check if its category matches the declared config
echo "$FEEDS" | jq -c '.[]' | while read -r feed; do
  FEED_ID=$(echo "$feed" | jq -r '.id')
  FEED_URL=$(echo "$feed" | jq -r '.feed_url')
  CURRENT_CATEGORY=$(echo "$feed" | jq -r '.category.title')

  # Look up the desired category for this feed URL
  DESIRED_CATEGORY=$(jq -r --arg url "$FEED_URL" '.[$url] // empty' "$FEED_CATEGORY_MAP")

  if [ -n "$DESIRED_CATEGORY" ] && [ "$DESIRED_CATEGORY" != "$CURRENT_CATEGORY" ]; then
    # Find the category ID for the desired category
    CATEGORY_ID=$(echo "$CATEGORIES" | jq -r --arg title "$DESIRED_CATEGORY" '.[] | select(.title == $title) | .id')

    if [ -n "$CATEGORY_ID" ]; then
      echo "Moving feed '$FEED_URL' from '$CURRENT_CATEGORY' to '$DESIRED_CATEGORY' (category_id=$CATEGORY_ID)"
      curl -sf -X PUT \
        -u "$ADMIN_USERNAME:$ADMIN_PASSWORD" \
        -H "Content-Type: application/json" \
        -d "{\"category_id\": $CATEGORY_ID}" \
        "$MINIFLUX_URL/v1/feeds/$FEED_ID" > /dev/null
    else
      echo "Warning: Category '$DESIRED_CATEGORY' not found, skipping feed '$FEED_URL'"
    fi
  fi
done

echo "Feed sync complete"
