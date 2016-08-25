PROJECT_PATH="$( dirname "$( readlink -e "$0" )" )"
php-fpm -p "${PROJECT_PATH}" -y "${PROJECT_PATH}"/php-fpm.conf -c "${PROJECT_PATH}"/php.ini &
nginx -p "${PROJECT_PATH}" -c "${PROJECT_PATH}"/nginx.conf
