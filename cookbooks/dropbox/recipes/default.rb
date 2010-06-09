#
# Cookbook Name:: dropbox
# Recipe:: default
#

user = node.etc.passwd[node.current_user]
raise "ERROR: valid user #{user} not found on system." unless user
home_dir = user.dir
raise "ERROR: user #{user} must have a valid home dir." unless home_dir

OUTPUT_FILE = "dropbox.log"
DROPBOX_EXEC = "#{home_dir}/.dropbox-dist/dropboxd"

platform = node.kernel.machine
suffix = (platform == "x86_64") ? platform : "x86"

bash "download dropbox" do
  not_if do ::File.exists?(DROPBOX_EXEC) end
  cwd home_dir
  code <<-EOH
    wget -O dropbox.tar.gz http://www.getdropbox.com/download?plat=lnx.#{suffix}
    tar zxof dropbox.tar.gz
  EOH
end

bash "download CLI tool" do
  not_if do ::File.exists?("/usr/local/bin/dropbox.py") end
  cwd home_dir
  code <<-EOH
    wget -P /usr/local/bin http://www.dropbox.com/download?dl=packages/dropbox.py
    mv /usr/local/bin/dropbox.py /usr/local/bin/dropbox.py
    chmod 755 /usr/local/bin/dropbox.py
    /usr/local/bin/dropbox.py help
  EOH
end

ruby_block "check download" do
  not_if do ::File.exists?(DROPBOX_EXEC) end
  block do
    raise "ERROR: unable to download dropbox!"
  end
end

template "#{home_dir}/.dropbox-dist/dropbox.sh" do
  source "dropbox.sh.erb"
  mode "770"
end

# Add init.d script for dropdox
template "/etc/init.d/dropbox" do
  Chef::Log.info("Update template.")
  source "init_dropbox.erb"
  mode "770"
end

# Call service resource to ensure dropbox is running
service "dropbox" do
#  supports [ :status ] 
  Chef::Log.info("Enable service.")
  action [ :enable, :start ]
end

ruby_block "wait for log file" do
  block do
    Chef::Log.info "Waiting for logfile to exist.."
    60.times do
      break if ::File.exists?("#{home_dir}/#{OUTPUT_FILE}")
      Chef::Log.info "  retrying..."
      sleep 5
    end
    raise "Dropbox logfile not found. Unable to register instance!. Fail." unless ::File.exists?("#{home_dir}/#{OUTPUT_FILE}")
  end
end

ruby_block "register instance" do
  only_if do ::File.exists?("#{home_dir}/#{OUTPUT_FILE}") end
  not_if do ::File.directory?("#{home_dir}/Dropbox") end
  block do
    # wait for the log to catchup and have the registration link
    sleep 10
    Chef::Log.info("Registering instance with dropbox website...")
    
    data = "--data-urlencode login_email=#{node[:dropbox][:email]} "
    data << "--data-urlencode login_password=#{node[:dropbox][:password]} "
    data << "-d 'login_submit=Log in' "
    data << "-d remember_me=on "
    data << "-d t=791206fc33 "

    link_line = `grep "link this machine" #{home_dir}/#{OUTPUT_FILE}`
    words = link_line.split
    url = words[2]
    data << "-d cont=#{url}"
    
    Chef::Log.info "Registering instance using URL: #{url}"
    cmd = "curl -L -c cookies.txt #{data} -o #{home_dir}/dropbox_register.log --url https://www.dropbox.com/login"
    Chef::Log.info "Running command: #{cmd}"
    Kernel.system(cmd)
  end
end


