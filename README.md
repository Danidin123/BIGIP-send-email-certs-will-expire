# BIGIP-send-email-certs-will-expire

The script bigip_check_cert.sh will check if there are any certificates that will be expired in 60, and if so till will execute the script send_mail_with_attachment.sh that will send an email with an attachment with a list of those certificates.

(If you want to use Gmail as smtp server) <br />
You need to edit the file /etc/ssmtp/ssmtp.conf, and add the below lines: <br />
mailhub=smtp.gmail.com:465 <br />
UseSTARTTLS=no <br />
UseTLS=yes <br />
AuthUser=XXXX <br />
AuthPass=XXXX <br />
TLS_CA_FILE=/etc/ssmtp/ca-bundle.crt <br />

For tests, you can use that command to create a certifiacte on the BIGIP: <br />
tmsh create sys crypto key SOL1testcert gen-certificate lifetime 20 common-name SOL1testcert.com


