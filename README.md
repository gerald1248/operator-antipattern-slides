# operator-antipattern-slides

To start the presentation, run `make`.

To update the SVG and PNG images, run `make mermaid`.

To copy the images to the presentation, run `make copy`.

## Installation
Your key dependencies are markdeck, npm, mmdc (which in turn requires puppeteer) and google-chrome.

```
curl -Lo markdeck https://github.com/arnehilmann/markdeck/releases/download/v0.60.0/markdeck.x86_64-unknown-linux-musl
chmod a+rx ./markdeck
sudo apt install npm
sudo npm install -g @mermaid-js/mermaid-cli
wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
sudo dpkg -i google-chrome-stable_current_amd64.deb
# if the previous command raises dependency issues, follow up with:
sudo apt --fix-broken install
```
