# Paint Shop Pro

A mobile-first paint-shop stock, sales, purchasing, expense and marketplace application for small businesses in Kenya.

## Start here
1. In Supabase SQL Editor, run `supabase/paint_shop_schema.sql` once.
2. Enable Email/Password under Supabase Authentication.
3. Open the site, create an account, confirm your email if prompted, then sign in.
4. Create your shop profile. Add products, record purchases and sales, and publish selected products to the public marketplace.

## Features
- Secure account sign-in and shop profile
- Paint product catalogue, brands, colours, sizes, quantities and low-stock alerts
- Sales, payment balances, receipt numbers and stock deductions
- Purchases and stock additions
- Supplier and customer directories
- Expense tracking and CSV export
- Public marketplace catalogue showing only published products and selling prices
- Responsive layout for Android phones and desktop browsers

## Data safety
All business data uses the separate `hps_*` tables and Supabase Row Level Security. The browser uses only the project's publishable key; never put a Supabase secret/service-role key in frontend code. Public marketplace listings intentionally do not expose buying prices, sales, expenses, or customer records.

## Deployment
This repository is static HTML/CSS/JavaScript. It can be published with GitHub Pages or deployed to Vercel from the repository root. The public catalogue is `marketplace.html`.

## Supabase
Project URL is configured in `app.js` and `marketplace.js`. Schema file: `supabase/paint_shop_schema.sql`.
