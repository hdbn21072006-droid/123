# Build stage
FROM node:18-alpine AS builder

WORKDIR /app

# Copy package files
COPY package*.json ./
COPY backend-package.json ./

# Install dependencies
RUN npm install

# Copy source code
COPY . .

# Build backend
RUN npx tsc -p tsconfig.backend.json

# Production stage
FROM node:18-alpine

WORKDIR /app

# Copy package files
COPY package*.json ./
COPY backend-package.json ./

# Install production dependencies only
RUN npm install --production

# Copy built files from builder
COPY --from=builder /app/dist-backend ./dist-backend
COPY --from=builder /app/src/backend ./src/backend

# Create uploads directory
RUN mkdir -p src/backend/uploads

EXPOSE 8080

ENV NODE_ENV=production
ENV PORT=8080

CMD ["node", "dist-backend/index.js"]
