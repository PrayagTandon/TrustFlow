FROM node:16-alpine

WORKDIR /app

# Install dependencies
COPY package*.json ./
RUN npm install -g ganache-cli truffle && \
    npm install

# Copy all files
COPY . .

# Expose ports
EXPOSE 3000 8545

# Start both services
CMD ["sh", "-c", "ganache-cli --deterministic --gasLimit 8000000 & npm start"]