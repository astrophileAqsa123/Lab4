FROM node:22-alpine AS frontend
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
RUN npm run build

FROM php:8.4-cli
RUN apt-get update && apt-get install -y 
    git unzip libzip-dev libsqlite3-dev 
    && docker-php-ext-install pdo_sqlite zip 
    && rm -rf /var/lib/apt/lists/*

COPY --from=composer:latest /usr/bin/composer /usr/bin/composer
WORKDIR /var/www

COPY composer.json composer.lock ./
RUN composer install --no-interaction --prefer-dist --no-dev --no-scripts

COPY . .
COPY --from=frontend /app/public/build ./public/build

RUN composer dump-autoload --optimize --no-scripts 
    && php artisan package:discover --ansi 
    && mkdir -p storage/logs bootstrap/cache database 
    && chmod -R ug+rwX storage bootstrap/cache

EXPOSE 8000
CMD ["sh", "-c", "mkdir -p database && touch database/database.sqlite && php artisan migrate --force && php artisan serve --host=0.0.0.0 --port=8000"]
