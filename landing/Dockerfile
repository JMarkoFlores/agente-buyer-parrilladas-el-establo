FROM node:24-alpine AS build
WORKDIR /app
# Build arg: base de la API inlineada por Astro (PUBLIC_*)
ARG PUBLIC_API_URL=https://elestablo.giansmd.dev
ENV PUBLIC_API_URL=$PUBLIC_API_URL
RUN corepack enable
COPY package.json pnpm-lock.yaml pnpm-workspace.yaml ./
RUN pnpm install --frozen-lockfile
COPY . .
RUN pnpm build

FROM nginx:1.27-alpine
COPY nginx.conf /etc/nginx/conf.d/default.conf
COPY --from=build /app/dist /usr/share/nginx/html
EXPOSE 80

HEALTHCHECK --interval=15s --timeout=5s --start-period=5s --retries=3 \
  CMD wget --quiet --tries=1 --spider http://127.0.0.1:80/ || exit 1

CMD ["nginx", "-g", "daemon off;"]
