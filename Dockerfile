# Use Node.js base image
FROM node:18
 
# Set working directory
WORKDIR /app
 
# Install Truffle globally
RUN npm install -g truffle
 
# Copy project files (contracts, migrations, etc.)
COPY . .
 
# Expose ports for blockchain
EXPOSE 7545
 
# Run Ganache & deploy contracts
CMD ["sh", "-c", "truffle migrate --network development && tail -f /dev/null"]