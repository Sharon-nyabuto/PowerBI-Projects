# Safari Connect Performance Dashboard

## Overview

Safari Connect is a Nairobi-based bus and matatu booking platform. This project analyses booking data from August 2024 to April 2025 to understand revenue performance, route performance, driver performance, passenger trends, and cancellations.

The analysis was built around four business questions:

1. Which routes make the most money?
2. Which drivers are performing best?
3. When is demand highest?
4. How much revenue is lost through cancellations?

## Data

The dataset contains booking, passenger, route, vehicle, driver, fare, payment, and trip rating information.

The raw data had several quality issues, including:

* Inconsistent text formatting
* Different phone number formats
* Inconsistent gender values
* Missing trip ratings for cancelled and no-show bookings
* Duplicate-looking records
* Inconsistent date formats

The data was cleaned and standardised using PostgreSQL before analysis.

## Dashboard

The Power BI dashboard provides an overview of:

* Total revenue and bookings
* Cancellation rate
* Average fare and trip rating
* Revenue by route
* Revenue by vehicle type
* Revenue by driver
* Revenue trends
* Revenue by seat class
* Passenger distribution by city
* Average fare by route
* Route-level performance and ratings

## Key Findings

### Route performance

**RT001**, the Nairobi to Mombasa route, is the strongest-performing route, generating KES **62,000** in revenue. RT004 and RT002 follow at KES **45,000** each.

RT005, RT008, and RT009 are the lowest revenue-generating routes at KES **9,000** each.

### Driver performance

Kelvin Omondi and Brian Kamau generated the highest revenue at KES 36,000 each, followed by Isaac Korir at KES 35,000.

Driver ratings are generally high, with all drivers scoring above 4.0.

### Passenger and vehicle trends

Nairobi is the largest source of passengers by a significant margin.

Buses consistently contribute the most revenue, while minibuses contribute the least.

Economy Class generates more total revenue than Business Class, although Business Class has a higher fare per seat.

### Customer experience

The overall average trip rating is **3.53** out of 5.

Nairobi to Kisumu has the highest passenger rating at **3.96**, while Nairobi to Nyeri has the lowest at **3.23**.

### Cancellations

There were 21 cancelled bookings out of 289, giving a cancellation rate of **7.27%.**

Using the average fare of KES 902.63, this represents approximately KES 18,955 in potential lost revenue.

The current data does not provide enough detail to identify clear peak travel times. A more detailed analysis of departure times would be needed.

## Recommendations

### 1. Focus on the Nairobi to Mombasa route

RT001 is the strongest revenue-generating route and also has the highest average fare. Safari Connect should consider increasing departure options and exploring opportunities to grow Business Class bookings on this route.

### 2. Recognise and learn from top-performing drivers

Kelvin Omondi and Brian Kamau are the top revenue-generating drivers. Their performance can be used to identify practices that could be shared with other drivers through training and performance management.

### 3. Reduce cancellation-related revenue loss

With approximately KES 19,000 in potential lost revenue from cancellations, Safari Connect should consider introducing a cancellation policy or deposit to reduce avoidable cancellations.

## Tools Used

| Tool            | Purpose                                   |
| --------------- | ----------------------------------------- |
| Microsoft Excel | Raw data storage                          |
| PostgreSQL      | Data cleaning and analysis                |
| Power BI        | Dashboard and visualisation               |

