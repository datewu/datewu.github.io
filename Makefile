.PHONY: dev
dev:
	-@hugo server -D

.PHONY: clean
clean:
	-@git submodule deinit -f .
	-@git submodule update --init --recursive
	-@git submodule update --remote --merge