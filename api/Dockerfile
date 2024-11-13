# Use Node.js as the base image
FROM node:18-alpine

# Set the working directory
WORKDIR /app

# Copy package.json and package-lock.json files to the working directory
COPY package*.json ./

# Install dependencies
RUN npm install --production

# Copy the entire application to the container
COPY . .

# Build the application
RUN npm run build

# Expose the port your NestJS app runs on
EXPOSE 3000

# Start the application
CMD ["npm", "run", "start:prod"]
