#!/bin/sh
OWNER=www-data
GROUP=www-data
sudo find . -type d -exec chmod 575 {} \;
sudo find . -type f -exec chmod 464 {} \;
sudo chmod 460 wp-config.php 
sudo chmod 775 .
sudo chown $OWNER:$GROUP -R .
sudo chown root:$GROUP .
