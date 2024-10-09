# Use Node.js as the base image for building the app
FROM node:18 AS build

# Set the working directory
WORKDIR /app

# Copy the package.json and package-lock.json
COPY package.json package-lock.json ./

# Install dependencies
RUN npm install

# Copy the .env file (make sure this file exists in your local directory)
COPY .env* ./

# Copy the rest of the application files
COPY . .

# Build the React application
RUN npm run build

# Use Nginx to serve the application
FROM nginx:alpine

# Copy the build files to Nginx's html directory
COPY --from=build /app/build /usr/share/nginx/html

# Expose the port Nginx is listening on
EXPOSE 80

# Start Nginx
CMD ["nginx", "-g", "daemon off;"]
