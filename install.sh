#!/bin/sh

# If anything fails, then fail the entire script.
set -e

echo "" > install/install.log
echo "Performing local branch"
git checkout -b deploy v22.3

echo "Installing apt packages"
sudo apt-get install ruby1.8-dev build-essential irb1.8 libreadline-ruby1.8\
                     libreadline5 rdoc1.8 rubygems1.8 libsqlite3-dev sqlite3\
                     libsqlite3-0 libxslt1-dev libxslt1.1 libsqlite3-dev\
                     libxml2-dev nginx >> install/install.log

echo "Performing manual gem update"
echo "see: http://stackoverflow.com/questions/2777831"
sudo gem install rubygems-update >> install/install.log
sudo /var/lib/gems/1.8/bin/update_rubygems >> install/install.log

# Install the core gems
echo "Installing gem: bundler"
sudo gem install bundler >> install/install.log
echo "Installing gem: thin"
sudo gem install thin >> install/install.log

# Install the Integrity gems in the Gemfile
echo "Installing Integrity gems"
sudo bundle install >> install/install.log

echo "Building the Integrity DB"
rake db

# Apply nginx site configuration
compare_files "/etc/nginx/sites-available/default" "install/nginx_site_default"
echo "Moving nginx site config into place"
cp install/nginx_site_integrity /etc/nginx/sites-available/default >> install/install.log

RANDOMSTRING=`random_string`
echo "Your random string is: $RANDOMSTRING" >> install/install.log
sed -ie "s/SECRETGITTOKEN/$RANDOMSTRING/" init.rb >> install/install.log

echo "We are done here. Your GitHub token is: $RANDOMSTRING"

# Create a random MD5 sum
function random_string {
    echo `dd if=/dev/urandom  bs=2048 count=100 2> /dev/null | md5sum -b | awk '{print $1}'`
}

# Check to see if too files are equal with MD5 sum
# Arg0 is the local file
# Arg1 is the provided file
function compare_files {
    if ! diff -q "${0}" "${1}" > /dev/null; then
        echo "Refusing to continue: ${0} has changed."
        diff /etc/nginx/sites-available/default install/nginx_default
        exit 1
    fi
}
