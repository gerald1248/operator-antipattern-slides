.PHONY: mermaid copy pdf

all:
	cd slides && ../markdeck

mermaid:
	cd mermaid/ && ./update.sh
	rm mermaid/*.png
	rm mermaid/*.svg

copy:
	cp png/*.png slides/assets/img/

pdf:
	decktape http://localhost:8080/ slides/operator-antipattern.pdf --chrome-path=/usr/bin/google-chrome
