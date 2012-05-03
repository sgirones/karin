karin
=====

Web based abiquo installer

Install
=======

git clone git@github.com:sgirones/karin.git

gem update --system

gem install bundler

yum install make mysql-devel gcc-c++

cd karin

bundle install

padrino start
