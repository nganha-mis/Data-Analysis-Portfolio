# Bùi Ngân Hạ — Data Analyst Portfolio

## About

Hi, I'm Hạ! I'm a final-year student majoring in **Management Information Systems** at National Economics University, Hanoi (GPA 3.8/4.0, Vietcombank Scholarship 2025).

I have a strong interest in data analytics, business intelligence, and turning raw data into actionable insights. My experience spans the full analytics workflow — from data cleaning in SQL to building interactive dashboards in Tableau and Power BI, and presenting findings as data-driven business recommendations.

I'm particularly drawn to **game analytics and player behavior analysis**, having completed an end-to-end Mobile In-App Purchase project that mirrors real game studio workflows. I enjoy finding the "counterintuitive" insight hidden in data — the kind that challenges assumptions and leads to better decisions.

📄 My CV: [CV_DA_Intern_BuiNganHa.pdf](#) *(update link after upload)*
🔗 LinkedIn: [linkedin.com/in/ha-ngan](#) *(update link)*
📧 Email: buinganha.nitc@gmail.com

---

## Table of Contents

- [Portfolio Projects](#portfolio-projects)
  - [SQL + Tableau · Mobile In-App Purchase Analytics](#1-mobile-in-app-purchase-analytics)
  - [Power BI · Vietnam Tourism Revenue Dashboard](#2-vietnam-tourism-revenue--booking-performance-dashboard)
  - [SQL · Human Resource Management System](#3-human-resource-management-system)
  - [SQL + C# · Library Management System](#4-library-management-system)
- [Skills](#skills)
- [Education](#education)
- [Contact](#contact)

---

## Portfolio Projects

### 1. Mobile In-App Purchase Analytics

**Tools:** SQL Server · Tableau  
**Dashboard:** [[View on Tableau Public](#) ]([url](https://public.tableau.com/app/profile/ha.ngan/viz/Project_17783070672660/Story1?publish=yes)) 
**SQL Scripts:** [`mobile_iap_cleaning.sql`] 
**Dataset:** [Mobile Game In-App Purchases Dataset 2025 — Kaggle](https://www.kaggle.com/datasets/pratyushpuri/mobile-game-in-app-purchases-dataset-2025)

**Goal:** Analyze player spending behavior and in-app purchase patterns of a mobile game to surface monetization insights and actionable recommendations.

**Description:**  
End-to-end analytics project on a 3,024-user mobile game IAP dataset. The project covered the full workflow: data cleaning in SQL, building 3 interactive Tableau dashboards, and presenting findings as a Tableau Story with business recommendations.

**Data Cleaning (SQL):**
- Handled null values across 14 columns
- Standardized categorical fields (SpendingSegment, User_Status, GameGenre, Device)
- Removed duplicates and validated Purchase_Amount ranges
- Formatted date fields for time-series analysis

**Dashboards built:**

| Dashboard | Focus | Key Charts |
|---|---|---|
| Revenue Performance Overview | Revenue trends & geography | Monthly trend + 7-day rolling avg, Revenue by country, Day-of-week bar chart |
| Player Segmentation & Behavior | Who is spending | Pareto chart, Scatter plot, Age group bar, Cohort analysis |
| Game & Monetization Insights | What drives purchases | Genre treemap, Genre trend line, Payment method, iOS vs Android |

**Skills:** Data cleaning, exploratory data analysis, KPI design, user segmentation, data storytelling, Tableau calculated fields, table calculations, dashboard actions

**Technology:** SQL Server, Tableau (Calculated Fields, Table Calculations, Dual Axis, Story)

**Key Findings:**
- 🐋 **68 Whale users (2.2%)** generate **59.3% of total revenue** ($175,583 out of $296,259) — classic Pareto distribution
- 📉 **No correlation between session length and spending** — Whale users have the shortest avg session (17.9 min) vs Minnow users (20.1 min), yet spend 269x more ($2,582 vs $9.59)
- 📅 **Tuesday is the highest revenue day** ($51,848, avg $142/transaction) — outperforming Friday ($35,724) by 45%, counter to the common assumption that weekends drive the most purchases
- 👦 **Teen users (13–17) have the highest avg spend ($119)** — higher than Young adults (18–24) at $59, suggesting current UA targeting may be misaligned
- 💳 **Debit Card leads in both volume (433 transactions) and avg spend ($129/transaction)** — higher than Apple Pay ($82) by 58%

**Recommendations:**
1. Launch a **Whale Retention Program** (VIP perks, exclusive content) — losing 1 Whale = losing avg $2,582
2. Shift **Flash Sales to Tuesday–Thursday** instead of weekends
3. Implement a **First-Week Nurture Campaign** — Day 0 buyers spend $119 avg vs Day 1–3 buyers at $75
4. Adjust **UA targeting** to prioritize Teen and 35+ demographics over Young adults

---

### 2. Vietnam Tourism Revenue & Booking Performance Dashboard

**Tools:** Power BI  
**Dashboard:** [View on Power BI](#)  
**Dataset:** Vietnam Tourism Business Data (2022–2025)

**Goal:** Analyze revenue performance, booking behavior, and customer satisfaction of a Vietnamese travel business across 4 years to identify growth opportunities.

**Description:**  
Built an interactive Power BI dashboard analyzing tourism data from 2022 to 2025, covering destinations, tour types, customer segments, revenue, and satisfaction scores.

**Skills:** Data modeling, KPI design, time-series analysis, customer segmentation, business recommendations

**Technology:** Power BI

**Key Findings:**
- 💰 **Total Revenue: 21,999M VND** across 2022–2025, with peak season in **June–August**
- 🏖️ Top 3 destinations by revenue: **Phu Quoc (2.86B) · Da Nang (2.75B) · Nha Trang (2.53B)** — all beach destinations
- 🌊 **Beach tour type leads at 29.49%** of total bookings, followed by Family (21.41%) and Adventure (18.96%)
- ✅ **Booking Rate: 90.02%** — strong conversion from inquiry to confirmed booking
- 🔄 **Returning Rate: 66.38%** — 34% of customers do not rebook, representing a significant retention gap
- ⭐ **Average Satisfaction Score: 4.21/5**

**Recommendations:**
1. Expand premium Beach + resort combo packages targeting Phu Quoc, Da Nang, Nha Trang
2. Implement a personalized loyalty program to close the 34% churn gap and push Returning Rate toward 75–80%

---

### 3. Human Resource Management System

**Tools:** SQL Server · Figma  
**Code:** [`hr_management.sql`](#) *(update link after upload)*

**Goal:** Analyze and model HR business processes, then design a database system to automate leave tracking and payroll calculation.

**Description:**  
Personal project simulating the role of a Business Analyst and Database Designer. Focused on standardizing multi-level leave approval workflows across 10 HR modules and translating business requirements into a scalable database schema.

**Skills:** Business process analysis, ERD design, database logic (constraints, triggers, stored procedures), UML, Figma prototyping

**Technology:** SQL Server, Draw.io, Figma

**Key Deliverables:**
- Optimized ERD covering 10 HR modules with constraints ensuring data integrity
- Stored procedures to automate leave balance calculation and payroll impact
- UML activity diagrams modeling Employee – Manager – HR interactions
- Figma mockup of a data-driven HR dashboard for reporting and decision-making

---

### 4. Library Management System

**Tools:** SQL Server · C# WinForms  

**Goal:** Design and implement a library management system supporting book catalog, borrowing, and returning operations.

**Description:**  
Course project covering the full development cycle — from ERD design and database schema to UI implementation. Focused on ensuring data consistency and reducing redundancy across borrowing/returning transactions.

**Skills:** ERD design, SQL implementation, business logic, WinForms UI development

**Technology:** SQL Server, C# (WinForms)

---

## Skills

| Category | Tools & Technologies |
|---|---|
| Data Analysis | SQL Server · Python (Pandas, NumPy) · R · Excel |
| Visualization | Tableau · Power BI |
| Business Analysis | ERD Design · UML · Process Modeling (BFD, DFD, Flowchart) |
| Others | Draw.io · Figma · Microsoft Project · Git · C# (WinForms) |

---

## Education

**National Economics University** — Hanoi, Vietnam  
College of Technology — Management Information Systems  
*2023 – Present* | GPA: **3.8 / 4.0**  
🏆 Vietcombank Scholarship 2025  

Relevant coursework: Data Analysis · Database Design · Information Systems Analysis

---

## Contact

- 📧 Email: buinganha.nitc@gmail.com
- 💼 LinkedIn: [linkedin.com/in/ha-ngan](#) *(update link)*
- 📱 Phone: 0814 670 718
