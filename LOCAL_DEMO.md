# Local Demo Workflow

This local workflow does not satisfy the IBM Code Engine deployment rubric, but it lets you prove the app works end to end while your IBM account is unavailable.

## One-time setup

Run:

```zsh
chmod +x /Users/winny/Desktop/dealer_evaluation_frontend/scripts/start_local_demo.sh
chmod +x /Users/winny/Desktop/dealer_evaluation_frontend/scripts/capture_local_screenshots.sh
chmod +x /Users/winny/Desktop/dealer_evaluation_frontend/scripts/stop_local_demo.sh
/Users/winny/Desktop/dealer_evaluation_frontend/scripts/start_local_demo.sh
```

The helper script:

- creates a Python virtual environment at `/Users/winny/Desktop/dealer-eval-venv`
- installs the Python dependencies for the product service and frontend
- runs `npm ci` for the dealer pricing service
- starts all three services

## Local URLs

- Frontend: `http://127.0.0.1:5001`
- Product details API: `http://127.0.0.1:5002`
- Dealer pricing API: `http://127.0.0.1:8080`

The frontend uses `5002` for the product service because port `5000` is already occupied on this Mac.

## Screenshot order

1. Clone screenshot:
   Open `/Users/winny/Desktop/dealer_evaluation_frontend` in Finder or show `git clone` output in Terminal.
2. Code change screenshot:
   Open `/Users/winny/Desktop/dealer_evaluation_frontend/html/index.html` and capture the `produrl` and `dealerurl` lines.
3. Homepage screenshot:
   Use `/Users/winny/Desktop/dealer_evaluation_frontend/scripts/capture_local_screenshots.sh` or open `http://127.0.0.1:5001` and wait for the product dropdown to load.
4. Dealers screenshot:
   Select `Laptop` and capture the dealers dropdown.
5. Single price screenshot:
   Select `Tech City` for `Laptop` and capture the text price.
6. All dealers screenshot:
   Select `All Dealers` and capture the table with all laptop prices.

## Auto-generated local screenshots

Run:

```zsh
/Users/winny/Desktop/dealer_evaluation_frontend/scripts/capture_local_screenshots.sh
```

This writes:

- `/Users/winny/Desktop/dealer_homepage_products_expanded.png`
- `/Users/winny/Desktop/dealer_dealers_laptop_expanded.png`
- `/Users/winny/Desktop/dealer_single_price.png`
- `/Users/winny/Desktop/dealer_all_prices.png`

## Stop the demo

Run:

```zsh
/Users/winny/Desktop/dealer_evaluation_frontend/scripts/stop_local_demo.sh
```
