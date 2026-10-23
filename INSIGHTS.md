# Key Findings & Business Answers

---

## Business at a Glance

| Metric | Value |
|---|---|
| Total sales | $2,297,201 |
| Total profit | $286,397 |
| Profit margin | 12.47% |
| Orders | 5,009 |
| Customers | 793 |
| Average order value | $458.61 |
| Units sold | 37,873 |

---

## Part 1: EDA Key Findings

### 1. Sales are growing, and profit is growing with them
| Year | Sales | Profit | Margin | Sales growth |
|---|---|---|---|---|
| 2014 | $484K | $49.5K | 10.2% | n/a |
| 2015 | $471K | $61.6K | 13.1% | -2.8% |
| 2016 | $609K | $81.8K | 13.4% | +29.5% |
| 2017 | $733K | $93.4K | 12.7% | +20.4% |

Sales dipped slightly in 2015, then grew strongly. Margin improved after 2014 and has stayed near 13%.

### 2. Sales are seasonal
Average monthly sales peak in **November ($88K)**, **December ($81K)** and **September ($77K)**. January and February are the weakest (about $24K and $15K). Best single month: **November 2017 at $118K**.

### 3. Furniture sells a lot but earns very little
| Category | Sales | Profit | Margin |
|---|---|---|---|
| Technology | $836K | $145K | 17.4% |
| Furniture | $742K | $18K | **2.5%** |
| Office Supplies | $719K | $122K | 17.0% |

### 4. Three sub-categories lose money
| Sub-category | Sales | Profit | Margin |
|---|---|---|---|
| Tables | $207K | -$17.7K | -8.6% |
| Bookcases | $115K | -$3.5K | -3.0% |
| Supplies | $47K | -$1.2K | -2.5% |

**Machines** sells $189K but earns only a 1.8% margin. Strong earners are **Paper (43%)**, **Labels (44%)**, **Envelopes (42%)** and **Copiers (37%)**.

### 5. Discounts are the main cause of losses
| Discount | Order lines | Profit | Margin |
|---|---|---|---|
| None | 4,798 | $321.0K | 29.5% |
| 1–20% | 3,803 | $100.8K | 11.9% |
| 21–40% | 460 | -$35.8K | -15.3% |
| Over 40% | 933 | -$99.6K | **-77.4%** |

At a 30% discount, 92% of order lines lose money, and from 45% upward every order line does. Tables, Machines and Binders carry the highest average discounts (26%, 31%, 37%).

### 6. 301 of 1,850 products (16.3%) lose money overall
About **18.7%** of all order lines (1,871) are loss-making. They were kept in the data because they are real sales.

### 7. West and East lead; Central is weakest
| Region | Sales | Profit | Margin | Avg order value |
|---|---|---|---|---|
| West | $725K | $108K | 14.9% | $450 |
| East | $679K | $92K | 13.5% | $485 |
| Central | $501K | $40K | **7.9%** | $427 |
| South | $392K | $47K | 11.9% | $477 |

Central sells more than South but earns less profit.

### 8. Customer types
Consumer brings 50.6% of sales, Corporate 30.7% and Home Office 18.7%. Home Office has the best margin (14.0%) and Consumer the lowest (11.5%).

---

## Part 2: SQL Business Questions & Answers

| # | Business question | Answer |
|---|---|---|
| KPI | What are the headline numbers? | $2.30M sales, $286K profit, 12.47% margin, 5,009 orders, 793 customers, $458.61 average order value |
| Q1 | Which category earns the most? | **Technology** leads on sales (36.4% of total, $836K) and profit ($145K). Furniture holds 32.3% of sales but only $18K profit. |
| Q3 | Which sub-categories lose money? | **Tables, Bookcases and Supplies**, together about -$22K. |
| Q4 | Does discounting hurt profit? | Yes. Margin drops from 29.5% (no discount) to -15.3% (21–40%) and -77.4% (over 40%). |
| Q5 | Which regions rank best? | **West** ranks 1st on both sales and margin. **Central** ranks 3rd on sales but last on margin (7.9%). |
| Q6 | How is sales growing year over year? (CTE + `LAG`) | 2015: -2.8%, 2016: +29.5%, 2017: +20.4%. Profit grew every year (+24%, +33%, +14%). |
| Q7 | What is the monthly trend? (CTE + `LAG` + running total) | Clear seasonal peaks in Sep, Nov and Dec each year. Weakest months are Jan–Feb. |
| Q10 | Top 3 products per category? (`ROW_NUMBER`) | **Technology:** Canon imageCLASS 2200 Copier ($61.6K), Cisco TelePresence EX90 ($22.6K), HP LaserJet 3310 Copier ($18.8K). **Office Supplies:** Fellowes PB500 Binding Machine ($27.5K), GBC DocuBind TL300 ($19.8K), GBC Ibimaster 500 ($19.0K). **Furniture:** HON 5400 Task Chairs ($21.9K), Riverside Palais Royal Bookcase ($15.6K), Bretford Conference Table Tops ($13.0K). |
| Q12 | Repeat vs. one-time buyers? (CTE) | 781 of 793 customers (98.5%) are repeat buyers, averaging 6.3 orders. Only 12 bought once and they make 0.2% of revenue. |
| Q13 | How fast do we ship? | Same Day 0.04 days, First Class 2.2, Second Class 3.2, Standard 5.0 (max 7 days). |
| Q14 | Which top-10 states lose money? | Of the 10 biggest states, **Texas (-$25.7K), Ohio (-$17.0K), Pennsylvania (-$15.6K), Illinois (-$12.6K) and Florida (-$3.4K)** lose money despite strong sales. California and New York earn the most profit ($76K and $74K). |
| Q15 | Which customers may churn? (CTE) | **202 customers** have not ordered for 180+ days, measured from the last date in the data (30 Dec 2017). |

### Top Locations
- **States by sales:** California ($458K), New York ($311K), Texas ($170K), Washington ($139K), Pennsylvania ($117K)
- **Cities by sales:** New York City ($256K), Los Angeles ($176K), Seattle ($120K)

---

## Part 3: Customer Segmentation (RFM)

Each customer is scored 1–5 on how recently they bought (**R**), how often (**F**), and how much they spent (**M**), then placed in one of four segments.

| Segment | Customers | % of customers | Avg days since last order | Avg orders | Avg spend | Revenue | % of revenue |
|---|---|---|---|---|---|---|---|
| Champions | 224 | 28.2% | 27 | 8.2 | $4,098 | $918K | 40.0% |
| Loyal | 252 | 31.8% | 58 | 5.8 | $2,356 | $594K | 25.8% |
| At Risk | 132 | 16.6% | 234 | 7.5 | $4,341 | $573K | 24.9% |
| Lost | 185 | 23.3% | 356 | 4.0 | $1,148 | $212K | 9.2% |

---

## Recommendations

1. **Cap discounts at 20%.** Orders above 30% almost always lose money.
2. **Review pricing and discounts on Tables, Bookcases, Supplies and Machines.** They sell well but earn little or lose money.
3. **Fix Furniture margins**, which are 2.5% against about 17% elsewhere.
4. **Investigate Texas, Ohio, Pennsylvania and Illinois.** Strong sales, negative profit.
5. **Run a win-back campaign for At Risk customers**, starting with the highest spenders.
6. **Reward Champions** with early access or loyalty perks to protect 40% of revenue.
7. **Stock up and promote before September–December**, the strongest sales months.
8. **Look at the Central region**, where margin is only 7.9%.

