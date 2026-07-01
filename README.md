# Olist E-Commerce Sales Analysis

Exploratory analysis of a real Brazilian e-commerce dataset with 100,000+ orders. I wanted to practice working with a messy relational dataset from start to finish, loading raw CSVs into SQL, writing queries to answer real business questions, and presenting findings in an Excel dashboard.

---

## Dataset

Olist Brazilian E-Commerce Public Dataset — available on [Kaggle](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce).

The data covers 2016-2018 and comes as 8 separate CSV files that needed to be joined together to answer most questions. The tables I used most were orders, order_items, customers, products, reviews, sellers, and a category translation table to convert Portuguese category names to English.

One thing worth noting upfront: revenue here refers to product price only and does not include shipping fees. Freight tends to be a pass-through cost rather than true sales revenue.

---

## Questions I Tried to Answer

1. Which product categories and states generate the most revenue?
2. Does delivery speed affect customer review scores?
3. What percentage of customers come back for a second order?
4. How has revenue trended month over month?
5. Who are the top sellers, and are high-revenue sellers also well-reviewed?

---

## Tools

- SQLite + DB Browser for SQLite
- Microsoft Excel

---

## Findings

### Revenue by Category and Region

Health Beauty and Watches & Gifts came out on top by a decent margin. The full top 5:

| Category | Revenue |
|----------|---------|
| Health Beauty | $1,258,681 |
| Watches & Gifts | $1,205,006 |
| Bed Bath & Table | $1,036,989 |
| Sports Leisure | $988,049 |
| Computers Accessories | $911,954 |

Sao Paulo (SP) dominates by state, almost 3x the revenue of Rio de Janeiro in second place. That kind of concentration is worth paying attention to from a logistics and market expansion standpoint.

| State | Revenue |
|-------|---------|
| SP | $5,200,000+ |
| RJ | $1,800,000 |
| MG | $1,300,000 |
| RS | $600,000 |
| PR | $550,000 |

---

### Delivery Time vs Review Scores

I used JULIANDAY() to calculate the gap between when an order actually arrived and when it was estimated to arrive. Negative numbers mean it arrived early.

| Review Score | Avg Days vs Estimate |
|-------------|---------------------|
| 1 | -4.3 days |
| 2 | -8.1 days |
| 3 | -9.8 days |
| 4 | -11.5 days |
| 5 | -12.8 days |

Everything arrived early on average, but the spread is interesting, 5-star orders arrived about 8.5 days earlier than 1-star ones. So it is not just about being on time, it is about being noticeably early. That suggests Olist might benefit from setting more conservative delivery estimates rather than just improving raw shipping speed.

---

### Repeat Customer Rate

This one required some care. The dataset has both a customer_id (which resets with every new order) and a customer_unique_id (which stays the same for the same person). Using the wrong one would make everyone look like a first-time buyer.

| Metric | Value |
|--------|-------|
| Total unique customers | 96,096 |
| Repeat customers | 2,997 |
| Repeat rate | 3.12% |

That is pretty low. Most customers placed exactly one order and never came back, which points to a retention problem worth digging into further.

---

### Monthly Revenue Trend

Revenue grew steadily from late 2016 through 2017, peaked around November 2017 (likely Black Friday/holiday season), then plateaued through mid-2018. The sharp drop at the very end of the dataset is just incomplete data for the last month, not a real collapse.

---

### Top Sellers

I looked at revenue, order volume, and average review score together rather than just sorting by revenue. One seller stood out, Seller 3 had the highest order volume (1,984 orders) and solid revenue (~$200K), but the lowest average review score among the top 10 (3.80). High output, lower quality signal.

Top 3 by revenue:

| Seller | Revenue | Orders | Avg Review |
|--------|---------|--------|------------|
| Seller 1 | $228,000 | 1,148 | 4.12 |
| Seller 2 | $220,000 | 408 | 4.08 |
| Seller 3 | $200,000 | 1,984 | 3.80 |

---

## Recommendations

1. SP is dominant but that concentration is also a risk. Worth investing in logistics in RJ and MG to reduce dependency and tap into underperforming markets.

2. Health Beauty and Watches & Gifts are clear winners. Lower-performing categories like Garden Tools and Auto are worth evaluating for continued investment.

3. The data suggests customers respond better to arriving noticeably early than arriving exactly on time. Setting more conservative delivery estimates could improve review scores without changing actual shipping speed.

4. A 3.12% repeat rate means the business is almost entirely dependent on new customer acquisition. A loyalty program or post-purchase email campaign seems like a reasonable next step.

5. Seller 3 has high volume but below-average satisfaction. Worth investigating before it starts affecting platform reputation.

---

## SQL Concepts Used

- Multi-table JOINs (2 and 3 table chains)
- CTEs including chained CTEs
- Window functions with LAG() OVER
- Date arithmetic with JULIANDAY() and STRFTIME()
- CAST to handle integer division
- COUNT(DISTINCT) for deduplication

---

## Project Structure

```
ecommerce-analysis/
├── olist.db               # SQLite database
├── olist_analysis.sql     # All queries with comments
├── olist_dashboard.xlsx   # Excel dashboard
└── README.md
```

Raw CSVs not included — download directly from the Kaggle link above.
