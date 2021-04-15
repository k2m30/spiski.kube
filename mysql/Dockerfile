FROM mysql:8.0.23

COPY init.sql /docker-entrypoint-initdb.d/init.sql
EXPOSE 3306
CMD ["--default-authentication-plugin=mysql_native_password", "--character-set-server=utf8mb4", "--collation-server=utf8mb4_unicode_ci"]

