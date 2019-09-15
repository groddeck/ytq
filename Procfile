redis: redis-server
search: QUEUE=search rake resque:work
extract: QUEUE=extract rake resque:work
playlist: QUEUE=playlist rake resque:work
web: ruby ytq.rb -o 0.0.0.0
loop_extract: ruby extract.rb
loop_autoplay: ruby autoplay.rb
loop_remove: ruby remove.rb
loop_search: ruby search.rb
