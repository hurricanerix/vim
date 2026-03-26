.PHONY: all clean install-plugins

VIM        := vim
LOCAL_VIM  := $(HOME)/.vim/local.vim
OS         := $(shell uname -s)

ifeq ($(OS), Darwin)
	PLATFORM_VIM := $(HOME)/.vim/darwin.vim
else ifeq ($(OS), Linux)
	PLATFORM_VIM := $(HOME)/.vim/linux.vim
else
	$(error Unsupported OS: $(OS))
endif

all: $(LOCAL_VIM) install-plugins

## Symlink the correct platform file to local.vim
$(LOCAL_VIM):
	@if [ ! -f "$(PLATFORM_VIM)" ]; then \
		echo "ERROR: $(PLATFORM_VIM) not found"; \
		exit 1; \
	fi
	@echo "Linking $(PLATFORM_VIM) -> $(LOCAL_VIM)"
	ln -sf $(PLATFORM_VIM) $(LOCAL_VIM)

## Install vim-plug plugins and Go binaries
install-plugins:
	@echo "Installing plugins..."
	$(VIM) +PlugInstall +qall
	@echo "Installing Go binaries..."
	$(VIM) +GoInstallBinaries +qall
	@echo "Done."

## Remove the local.vim symlink
clean:
	@echo "Removing $(LOCAL_VIM)"
	rm -f $(LOCAL_VIM)
