.PHONY: all bin dotfiles test shellcheck

all: bin dotfiles

bin:
	# add aliases for things in bin
	for file in $(shell find $(CURDIR)/bin -type f -not -name "*-backlight" -not -name ".*.swp"); do \
		f=$$(basename $$file); \
		sudo ln -sf $$file /usr/local/bin/$$f; \
	done

dotfiles:
	# add aliases for dotfiles
	for file in $(shell find $(CURDIR) -name ".*" -not -name ".gitlab-ci.yml" -not -name ".ssh" -not -name ".gitignore" -not -name ".travis.yml" -not -name ".git" -not -name ".*.swp" -not -name ".travis.yml" -not -name ".irssi" -not -name ".gnupg" -not -name ".gitconfig"); do \
        if [ -f $$file ]; then \
    		f=$$(basename $$file); \
	    	ln -sfn $$file $(HOME)/$$f; \
        fi; \
	done; \
	cp .gitconfig $(HOME)/.gitconfig

test: shellcheck

# if this session isn't interactive, then we don't want to allocate a
# TTY, which would fail, but if it is interactive, we do want to attach
# so that the user can send e.g. ^C through.
INTERACTIVE := $(shell [ -t 0 ] && echo 1 || echo 0)
ifeq ($(INTERACTIVE), 1)
	DOCKER_FLAGS += -t
endif

shellcheck:
	docker run --rm -i $(DOCKER_FLAGS) \
		--name df-shellcheck \
		-v $(CURDIR):/usr/src:ro \
		--workdir /usr/src \
		r.j3ss.co/shellcheck ./test.sh
