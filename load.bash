#!/bin/bash
set -euo pipefail

# Function to install jq if not already installed
install_jq() {
    if command -v jq >/dev/null 2>&1; then
        echo "jq is already installed."
    else
        echo "jq is not installed. Installing jq..."
        if [[ "$OSTYPE" == "darwin"* ]]; then
            brew install jq
        else
            echo "Unsupported OS. Please install jq manually."
            exit 1
        fi
    fi
}

# Used to parse curl output below
install_jq

# Clean Prisma DB
output=$(npx prisma db execute --file=src/prisma/clean.sql)

if [[ "$output" != *"Script executed successfully."* ]]; then
    echo "Prisma DB execute failed."
    exit 1
fi

echo "Section -- Start -- Auth"
USER1_USERNAME="testuser1"
USER1_PASSWORD="password"
USER1_EMAIL="testuser1@detail.dev"

create_user1_output=$(curl -s -X POST http://localhost:3000/api/users \
     -H "Content-Type: application/json" \
     -d "{\"user\": {\"username\": \"$USER1_USERNAME\", \"password\": \"$USER1_PASSWORD\", \"email\": \"$USER1_EMAIL\"}}")
echo "Created User 1"

login_user1_output=$(curl -s -X POST http://localhost:3000/api/users/login \
     -H "Content-Type: application/json" \
     -d "{\"user\": {\"email\": \"$USER1_EMAIL\", \"password\": \"$USER1_PASSWORD\", \"username\": \"$USER1_USERNAME\"}}")
echo "Logged in User 1"
echo "Section -- End -- Auth"
# Parse the token from the login response
USER1_LOGIN_TOKEN=$(echo "$login_user1_output" | jq -r '.user.token')
echo "Section -- Start -- Article"
create_first_article_output=$(curl -s -X POST http://localhost:3000/api/articles \
     -H "Content-Type: application/json" \
     -H "Authorization: Bearer $USER1_LOGIN_TOKEN" \
	   -d '{
         "article": {
           "title": "First article",
           "description": "This is my first article",
           "body": "The full content of the article",
           "tagList": ["tag1"]
         }
       }')
FIRST_ARTICLE_SLUG=$(echo "$create_first_article_output" | jq -r '.article.slug')

# Returns error that title isn't unique (great for testing) 
duplicate_first_article_output=$(curl -s -S -X POST http://localhost:3000/api/articles \
     -H "Content-Type: application/json" \
     -H "Authorization: Bearer $USER1_LOGIN_TOKEN" \
     -d '{
         "article": {
           "title": "First article",
           "description": "This is my first article",
           "body": "The full content of the article",
           "tagList": ["tag1"]
         }
       }')
create_second_article_output=$(curl -s -S -X POST http://localhost:3000/api/articles \
     -H "Content-Type: application/json" \
     -H "Authorization: Bearer $USER1_LOGIN_TOKEN" \
     -d '{
         "article": {
           "title": "Second article",
           "description": "This is my second article",
           "body": "The full content of the article",
           "tagList": ["tag1"]
         }
       }')
SECOND_ARTICLE_SLUG=$(echo "$create_second_article_output" | jq -r '.article.slug')
successful_update_first_article_output=$(curl -s -S -X PUT http://localhost:3000/api/articles/$FIRST_ARTICLE_SLUG \
     -H "Content-Type: application/json" \
     -H "Authorization: Bearer $USER1_LOGIN_TOKEN" \
     -d '{
           "article": {
             "title": "First article",
             "description": "This is my first article",
             "body": "The full content of the article, but now updated",
             "tagList": ["tag1"]
           }
         }')
unsuccessful_update_first_article_output=$(curl -s -S -X PUT http://localhost:3000/api/articles/$FIRST_ARTICLE_SLUG \
     -H "Content-Type: application/json" \
     -H "Authorization: Bearer $USER1_LOGIN_TOKEN" \
     -d '{
           "article": {
             "title": "Second article",
             "description": "This is my first article, but with a non-unique title",
             "body": "You should not be able to change one article into another article",
             "tagList": ["tag1"]
           }
         }')
delete_first_article_output=$(curl -s -S -X DELETE http://localhost:3000/api/articles/$FIRST_ARTICLE_SLUG \
     -H "Content-Type: application/json" \
     -H "Authorization: Bearer $USER1_LOGIN_TOKEN")

echo "Subsection -- Start -- Article comments"
# Second article is the only one up at this point
add_comment_output=$(curl -s -S -X POST http://localhost:3000/api/articles/$SECOND_ARTICLE_SLUG/comments \
     -H "Content-Type: application/json" \
     -H "Authorization: Bearer $USER1_LOGIN_TOKEN" \
     -d '{
           "comment": {
              "body": "This is my first comment"
           }
         }')
COMMENT_ID=$(echo "$add_comment_output" | jq -r '.comment.id')
delete_first_article_output=$(curl -s -S -X DELETE http://localhost:3000/api/articles/$FIRST_ARTICLE_SLUG/comments/$COMMENT_ID \
     -H "Content-Type: application/json" \
     -H "Authorization: Bearer $USER1_LOGIN_TOKEN")
echo "Subsection -- End -- Article comments"


echo "SubSection -- Start -- Article favorites"
favorite_article_output=$(curl -s -S -X POST http://localhost:3000/api/articles/$SECOND_ARTICLE_SLUG/favorite \
     -H "Content-Type: application/json" \
     -H "Authorization: Bearer $USER1_LOGIN_TOKEN" \
     -d '{}')
unfavorite_article_output=$(curl -s -S -X DELETE http://localhost:3000/api/articles/$SECOND_ARTICLE_SLUG/favorite \
     -H "Content-Type: application/json" \
     -H "Authorization: Bearer $USER1_LOGIN_TOKEN" \
     -d '{}')
echo "SubSection -- End -- Article favorites "

echo "Section -- End -- Article"
echo "Section -- Start -- Profile"
echo "Section -- End -- Profile"