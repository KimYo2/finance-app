const sharp = require('sharp');
const path = require('path');
const fs = require('fs');

const svgPath = path.join(__dirname, 'assets/images/logo.svg');
const outputDir = path.join(__dirname, 'assets/images');

fs.readFile(svgPath, 'utf8', (err, svgContent) => {
  if (err) {
    console.log('SVG not found, using PNG...');
    createFromPng();
    return;
  }
  console.log('SVG found, will use that');
});

async function createFromPng() {
  const pngPath = path.join(outputDir, 'logo.png');
  const size = 1024;
  
  await sharp(pngPath)
    .resize(size, size)
    .png()
    .toFile(path.join(outputDir, 'logo_icon.png'));
  console.log('Created logo_icon.png');
}

createFromPng().catch(console.error);