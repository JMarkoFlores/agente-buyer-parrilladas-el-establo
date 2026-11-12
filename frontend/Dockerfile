# ==============================================================================
# DOCKERFILE - FRONTEND REACT + TYPESCRIPT + VITE + NGINX
# Agente Inteligente Multicanal para la Captación y Conversión de BUYERS
# Parrilladas El Establo
# ==============================================================================

# Etapa 1: Compilación de la aplicación React
FROM node:20-alpine AS build

WORKDIR /app

# Instalar dependencias con npm ci para reproducibilidad exacta
COPY package.json package-lock.json ./
RUN npm ci

# Copiar el código fuente y archivos de configuración
COPY . .

# Typecheck y compilación del bundle para producción
RUN npm run build

# Etapa 2: Servidor Nginx ligero para producción
FROM nginx:1.27-alpine AS production

# Copiar configuración de proxy inverso y SPA
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Copiar el bundle compilado de React
COPY --from=build /app/dist /usr/share/nginx/html

EXPOSE 80

# Healthcheck de disponibilidad de Nginx
HEALTHCHECK --interval=15s --timeout=5s --start-period=5s --retries=3 \
  CMD wget --quiet --tries=1 --spider http://127.0.0.1:80/ || exit 1

CMD ["nginx", "-g", "daemon off;"]
