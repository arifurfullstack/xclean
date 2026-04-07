# Stage 1: Build
FROM oven/bun:1 AS build
WORKDIR /app

# Copy lockfile and package.json to install dependencies
COPY package.json bun.lock ./
RUN bun install --frozen-lockfile

# Copy the rest of the source code
COPY . .

# Run the build (Vite requires VITE_* env vars at build time)
RUN bun run build

# Stage 2: Serve with Nginx
FROM nginx:alpine
ENV PORT=80
COPY --from=build /app/dist /usr/share/nginx/html
COPY nginx.conf /etc/nginx/templates/default.conf.template
EXPOSE 80