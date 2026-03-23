#!/bin/zsh

set -euo pipefail

PLAYWRIGHT_DIR="$HOME/Desktop/dealer_playwright_tmp"

mkdir -p "$PLAYWRIGHT_DIR"

if [ ! -f "$PLAYWRIGHT_DIR/package.json" ]; then
  (
    cd "$PLAYWRIGHT_DIR"
    npm init -y >/dev/null
  )
fi

if [ ! -d "$PLAYWRIGHT_DIR/node_modules/playwright" ]; then
  (
    cd "$PLAYWRIGHT_DIR"
    npm install playwright >/dev/null
  )
fi

(
  cd "$PLAYWRIGHT_DIR"
  node <<'EOF'
const { chromium } = require('playwright');

(async () => {
  const browser = await chromium.launch({ headless: true });
  const page = await browser.newPage({ viewport: { width: 1440, height: 900 } });

  await page.goto('http://127.0.0.1:5001', { waitUntil: 'networkidle' });
  await page.waitForFunction(() => {
    const select = document.querySelector('#selProd');
    return select && select.options.length > 1;
  });

  await page.evaluate(() => {
    const select = document.querySelector('#selProd');
    select.size = select.options.length;
    select.style.width = '220px';
  });
  await page.screenshot({ path: '/Users/winny/Desktop/dealer_homepage_products_expanded.png', fullPage: true });

  await page.selectOption('#selProd', 'Laptop');
  await page.waitForFunction(() => {
    const select = document.querySelector('#selDealer');
    return select && select.options.length > 1;
  });

  await page.evaluate(() => {
    const prod = document.querySelector('#selProd');
    prod.size = prod.options.length;
    prod.style.width = '220px';
    const dealer = document.querySelector('#selDealer');
    dealer.size = dealer.options.length;
    dealer.style.width = '220px';
  });
  await page.screenshot({ path: '/Users/winny/Desktop/dealer_dealers_laptop_expanded.png', fullPage: true });

  await page.selectOption('#selDealer', 'Tech City');
  await page.waitForFunction(() => {
    const pricing = document.querySelector('#pricing');
    return pricing && pricing.textContent.includes('Laptop costs');
  });
  await page.screenshot({ path: '/Users/winny/Desktop/dealer_single_price.png', fullPage: true });

  await page.selectOption('#selDealer', 'All Dealers');
  await page.waitForFunction(() => document.querySelectorAll('#pricing table tr').length >= 3);
  await page.screenshot({ path: '/Users/winny/Desktop/dealer_all_prices.png', fullPage: true });

  await browser.close();
})();
EOF
)

echo "Saved screenshots to:"
echo "$HOME/Desktop/dealer_homepage_products_expanded.png"
echo "$HOME/Desktop/dealer_dealers_laptop_expanded.png"
echo "$HOME/Desktop/dealer_single_price.png"
echo "$HOME/Desktop/dealer_all_prices.png"
