.PHONY: dev
dev:
	-@hugo server -D

.PHONY: new
new:
	-@hugo new posts/$(t)/index.md

.PHONY: pic
pic:
	-@mv ~/Downloads/*.jpg content/posts/$(t) 2> /dev/null
	-@mv ~/Downloads/*.jpeg content/posts/$(t) 2> /dev/null
	-@mv ~/Downloads/*.png content/posts/$(t) 2> /dev/null
	-@mv ~/Downloads/*.gif content/posts/$(t) 2> /dev/null
	-@mv ~/Downloads/*.webp content/posts/$(t) 2> /dev/null

.PHONY: clean
clean:
	-@git submodule deinit -f .
	-@git submodule update --init --recursive
	-@git submodule update --remote --merge