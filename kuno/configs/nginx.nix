{
  services.nginx.commonHttpConfig = ''
    log_format stripped '[$time_local] '
                        '"$request" $status $body_bytes_sent '
                        '"$http_referer"';
    access_log /var/log/nginx/access.log stripped;
  '';
}
