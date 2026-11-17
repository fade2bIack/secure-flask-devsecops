# 1. Gunakan base image minimal dengan versi spesifik
FROM python:3.12-alpine

# 2. Update paket sistem untuk menutup celah keamanan OS
RUN apk update && apk upgrade --no-cache

# 3. Buat user & group non-root
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

# Set direktori kerja
WORKDIR /app

# 4. Install dependencies tanpa menyimpan cache
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# 5. Salin kode aplikasi dengan kepemilikan langsung ke non-root user
COPY --chown=appuser:appgroup app.py .

# Beralih ke user non-root
USER appuser

# Ekspos port aplikasi
EXPOSE 5000

# 6. Tambahkan Healthcheck untuk monitoring container
HEALTHCHECK --interval=30s --timeout=5s --start-period=5s --retries=3 \
  CMD wget --no-verbose --tries=1 --spider http://localhost:5000/health || exit 1

# Jalankan aplikasi
CMD ["python", "app.py"]