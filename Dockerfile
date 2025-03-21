# Stage 1: Build
FROM node:20-alpine AS builder

# Install only essential build dependencies
RUN apk add --no-cache --virtual .build-deps python3 make g++

WORKDIR /app

# Copy dependency files first for caching
COPY package.json yarn.lock* ./

# Install prod+dev dependencies but prune later
RUN npm ci --omit=optional --quiet

# Copy only necessary files for build
COPY contracts/ contracts/
COPY migrations/ migrations/
COPY truffle-config.js .

# Stage 2: Runtime
FROM node:20-alpine

WORKDIR /app

# Copy only essential files from builder
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/contracts ./contracts
COPY --from=builder /app/migrations ./migrations
COPY --from=builder /app/truffle-config.js .

# Install runtime dependencies (ganache as local dependency)
RUN npm install ganache@7.9.0 --omit=optional --quiet && \
    apk add --no-cache curl

# Create optimized startup script
RUN printf '#!/bin/sh\n\
npx ganache --server.host 0.0.0.0 --server.port 7545 --wallet.mnemonic "candy maple cake sugar pudding cream honey rich smooth crumble sweet treat" &\n\
until curl -s http://localhost:7545; do sleep 1; done\n\
npx truffle migrate --reset\n\
exec tail -f /dev/null' > start.sh && \
    chmod +x start.sh

# Cleanup unnecessary files
RUN rm -rf /tmp/* /var/cache/apk/* && \
    apk del .build-deps

EXPOSE 7545 8545

HEALTHCHECK --interval=30s --timeout=3s \
    CMD curl -sf http://localhost:7545 || exit 1

CMD ["./start.sh"]
