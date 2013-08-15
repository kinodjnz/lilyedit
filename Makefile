all: start

start:
	bundle exec unicorn

bundle-install:
	bundle install --path vendor/bundle --without production
