.PHONY: mermaid copy pdf

all:
	cd slides && ../markdeck

mermaid:
	cd mermaid/ && ./update.sh

copy:
	cp mermaid/*.png slides/assets/img/
	cp vega-lite/*.png slides/assets/img/

pdf:
	decktape http://localhost:8080/ slides/operator-antipattern.pdf --load-pause=1500 --chrome-path=/usr/bin/google-chrome
