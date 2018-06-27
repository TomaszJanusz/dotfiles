function generate_cert
    openssl req -new -newkey rsa:2048 -nodes -out $argv.csr -keyout $argv.key -subj "/C=PL/ST=Maz/L=Warsaw/O=Indoorway/OU=IT/CN=$argv"
end