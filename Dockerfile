 # Use Nginx as the base image
FROM nginx:alpine
# Copy our static file to the Nginx html directory
COPY index.html /usr/share/nginx/html/index.html 
