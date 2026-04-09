# Stage 1: Build
FROM oven/bun:1 AS build
WORKDIR /app

# Copy lockfile and package.json to install dependencies
COPY package.json bun.lock ./
RUN bun install --frozen-lockfile

# Copy the rest of the source code
COPY . .

# Vite env vars — baked into the JS bundle at build time
ARG VITE_SUPABASE_URL=https://seybtckozzdcjgdgcsdq.supabase.co
ARG VITE_SUPABASE_PUBLISHABLE_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNleWJ0Y2tvenpkY2pnZGdjc2RxIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzA0NTM1NzEsImV4cCI6MjA4NjAyOTU3MX0.hnN8fMfTlqyZA3WHDw07t4gvYPpM22I8jDBYYsOU9Bs
ARG VITE_SUPABASE_PROJECT_ID=seybtckozzdcjgdgcsdq

ENV VITE_SUPABASE_URL=$VITE_SUPABASE_URL
ENV VITE_SUPABASE_PUBLISHABLE_KEY=$VITE_SUPABASE_PUBLISHABLE_KEY
ENV VITE_SUPABASE_PROJECT_ID=$VITE_SUPABASE_PROJECT_ID

# Run the build
RUN bun run build

# Stage 2: Serve with Nginx
FROM nginx:alpine
COPY --from=build /app/dist /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf
EXPOSE 3000