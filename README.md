# operator-antipattern-slides

To update the SVG and PNG images, run `make`.

## Installation
Your key dependencies are npm, mmdc (which in turn requires puppeteer) and google-chrome.

```
sudo apt install npm
sudo npm install -g @mermaid-js/mermaid-cli
wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
sudo dpkg -i google-chrome-stable_current_amd64.deb
# if the previous command raises dependency issues, follow up with:
sudo apt --fix-broken install
```
