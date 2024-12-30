DL=downl
.PHONY: dev
dev:
	-@hugo server -D

.PHONY: new
new:
	-@hugo new -k post content/posts/$(t)/index.md

.PHONY: pic
pic:
	-@cp ~/$(DL)/*.jpg content/posts/$(t) 2> /dev/null
	-@cp ~/$(DL)/*.jpeg content/posts/$(t) 2> /dev/null
	-@cp ~/$(DL)/*.png content/posts/$(t) 2> /dev/null
	-@cp ~/$(DL)/*.gif content/posts/$(t) 2> /dev/null
	-@cp ~/$(DL)/*.webp content/posts/$(t) 2> /dev/null
	-@cp ~/$(DL)/*.svg content/posts/$(t) 2> /dev/null

.PHONY: clean
clean:
	-@git submodule deinit -f .
	-@git submodule update --init --recursive
	-@git submodule update --remote --merge
