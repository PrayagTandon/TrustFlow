# Use Node.js image
FROM node:18
 
# Set working directory
WORKDIR /app
 
# Copy package.json first (better caching)
COPY package*.json ./
 
# Install dependencies
RUN npm install
 
# Copy the entire React app
COPY . .
 
# Expose React's port
EXPOSE 3000
 
# Start the React app
CMD ["npm", "start"]