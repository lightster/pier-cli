install:
ifeq ($(wildcard /usr/local/bin/pier),)
	ln -sfn /vagrant/codebase/lightster/pier-cli/bin/pier /usr/local/bin/pier
endif
ifeq ($(wildcard /usr/local/bin/moor),)
	ln -sfn /vagrant/codebase/lightster/pier-cli/bin/moor /usr/local/bin/moor
endif
