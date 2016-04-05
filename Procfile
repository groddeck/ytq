redis: redis-server
extract: QUEUE=extract rake resque:work
playlist: QUEUE=playlist rake resque:work
web: ruby ytq.rb -o 0.0.0.0
