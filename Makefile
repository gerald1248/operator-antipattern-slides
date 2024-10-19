.PHONY: mermaid copy

all:
	cd slides && ../markdeck

mermaid:
	cd mermaid/ && ./update.sh
	rm mermaid/*.png
	rm mermaid/*.svg

copy:
	cp png/*.png slides/assets/img/
