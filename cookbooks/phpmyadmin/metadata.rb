maintainer       "Example Com"
maintainer_email "ops@example.com"
license          "Apache 2.0"
description      "Installs/Configures phpmyadmin"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.rdoc'))
version          "0.1"

recipe           "phpmyadmin::default", "Installs phpmyadmin"

attribute "phpmyadmin", :display_name => "phpmyadmin", :type => "hash"

attribute "phpmyadmin/mysql_host", 
  :display_name => "phpmyadmin", 
  :description => "The FQDN of the mysql server you would like to use and administrate", 
  :required => true, 
  :recipes => ["phpmyadmin::default"]

attribute "db/admin/user",
  :display_name => "Database Admin Username",
  :description => "The username of the database user that has 'admin' privileges.",
  :required => true,
  :recipes => ["phpmyadmin::default"]

attribute "db/admin/password",
  :display_name => "Database Admin Password",
  :description => "The password of the database user that has 'admin' privileges.",
  :required => true,
  :recipes => ["phpmyadmin::default"]
