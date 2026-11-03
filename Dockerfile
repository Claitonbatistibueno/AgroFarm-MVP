# =========================================================
# AgroFarm web container: Apache + PHP 8.2
# The database is external (Supabase in production, a Postgres container locally).
# All configuration comes from environment variables (12-factor), never from files in the image.
# =========================================================
FROM php:8.5-apache

# PDO PostgreSQL driver (Supabase). curl and fileinfo are already built in.
RUN apt-get update \
 && apt-get install -y --no-install-recommends libpq-dev \
 && docker-php-ext-install pdo_pgsql \
 && apt-get purge -y --auto-remove libpq-dev && apt-get install -y --no-install-recommends libpq5 \
 && rm -rf /var/lib/apt/lists/*

# Production PHP settings + Apache: honour .htaccess, hide version banners
COPY docker/php.ini /usr/local/etc/php/conf.d/agrofarm.ini
COPY docker/apache.conf /etc/apache2/conf-available/agrofarm.conf
RUN a2enconf agrofarm && a2enmod headers

WORKDIR /var/www/html
COPY --chown=www-data:www-data . .

# Uploads are the only folder Apache may write to (mount a volume here in production)
RUN mkdir -p uploads && chown -R www-data:www-data uploads

ARG APP_VERSION=dev
ENV APP_VERSION=${APP_VERSION} \
    APP_ENV=production \
    DB_PORT=5432 \
    DB_SSLMODE=require

EXPOSE 80
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
  CMD curl -fsS "http://localhost/health.php?probe=live" > /dev/null || exit 1
