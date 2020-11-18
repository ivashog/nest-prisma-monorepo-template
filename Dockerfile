FROM node:14-alpine AS builder

# Create api directory
WORKDIR /app

# A wildcard is used to ensure both package.json AND package-lock.json are copied
COPY package*.json ./
COPY database ./prisma/

# Install api dependencies
RUN npm install
# Generate database client, leave out if generating in `postinstall` script
# RUN npx database generate

COPY . .

RUN npm run build

FROM node:14-alpine

COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/package*.json ./
COPY --from=builder /app/dist ./dist

EXPOSE 3000
CMD [ "npm", "run", "start:prod" ]
