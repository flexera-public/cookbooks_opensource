maintainer       "RightScale opensource"
maintainer_email "opensource@rightscale.com"
license          "Apache 2.0"
description      "Installs/Configures mongodb"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.rdoc'))
version          "0.1"
recipe "mongodb::default", "installs MongoDB"

attribute "mongodb", :display_name => "MongoDB", :type => "hash"

attribute "mongodb/release", 
  :display_name => "MongoDB new releases", 
  :description => "By default this recipe will install the default Ubuntu package.  To override: Set this attribute to use newer sources direct from mongodb.  Valid values are 'stable', 'unstable', or 'snapshot').", 
  :required => false, 
  :recipes => ["mongodb::default"]

