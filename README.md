# BIGIP-send-email-certs-will-expire

The script bigip_check_cert.sh will check if there are any certificates that will be expired in 60, and if so till will execute the script send_mail_with_attachment.sh that will send an email with an attachment with a list of those certificates.

(If you want to use Gmail as smtp server)
You need to edit the file /etc/ssmtp/ssmtp.conf, and add the below lines:
mailhub=smtp.gmail.com:465
UseSTARTTLS=no
UseTLS=yes
AuthUser=XXXX
AuthPass=XXXX
TLS_CA_FILE=/etc/ssmtp/ca-bundle.crt


