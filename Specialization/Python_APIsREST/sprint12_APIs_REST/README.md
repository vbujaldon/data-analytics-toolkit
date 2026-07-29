# 📌 Sprint 12 — REST APIs with Python

## Description

This repository contains the practical exercises developed for **Sprint 12 – REST APIs**, focused on applying HTTP methods and status codes to query public APIs, filter data and store results using Pandas.

The project covers three progressive levels:
* Basic exploration with a **lab API** (JSONPlaceholder)
* Interaction with a **real public API** of free choice
* Data extraction from **Open Data BCN** (CKAN API)

---

## 📌 General Objectives

* Apply foundational knowledge of REST APIs to query, manipulate and store data using HTTP requests, interpreting status codes and transforming the retrieved information for further analysis.

---

## Specific Objectives

* Identify and use different types of public APIs, understanding their characteristics, structure and documentation to perform effective queries.
* Practice the use of HTTP methods and status code handling, recognising server responses and applying the appropriate method depending on the desired operation.
* Transform data obtained from an API into structured formats such as Pandas DataFrames, and save them to facilitate further analysis or integration with other tools.

---

## Project Structure

```
📁 Sprint_12_APIs
- PYTHON CODE: Sprint_12_APIs.ipynb
- opendata_bcn.csv
- Mapa conceptual APIs.JPG
- README.md
```

## 🗺️ Conceptual Map
Conceptual map summarising the key concepts covered in this sprint:
API definition, objectives, how it works (client → request → server → response),
HTTP methods (GET, POST, PUT, PATCH, DELETE), status codes and the difference
between API and REST API.
Handwritten by the author.

📎 `Mapa_conceptual_APIs.JPG`

---

## Exercises Overview

### Level 1 — Basic Exploration with JSONPlaceholder
Basic API lab using the public [JSONPlaceholder](https://jsonplaceholder.typicode.com) API.
* GET requests to `/posts`, `/users` and `/todos` — displaying total count and status code for each
* GET request to a non-existent resource to trigger a **404 error**
* POST request to create a new fictional post (title, body, userId) — display JSON response and status code
* PATCH request to partially update an existing post — display JSON response and status code
* DELETE request on a post — display JSON response and status code

### Level 2 — Interaction with a Real Public API
Free exploration using the [Public APIs](https://github.com/public-apis/public-apis) repository.
* Choose an API that supports GET requests and returns JSON
* Document at least two available endpoints and any optional filters or parameters
* Make a GET request and display the status code and selected fields from the JSON response
* Convert the response data into a Pandas DataFrame and display the first rows

### Level 3 — Open Data BCN (CKAN API)
Data extraction from the [Open Data Barcelona](https://opendata-ajuntament.barcelona.cat) portal.
* Search for a dataset of interest using `package_search` and `package_show`
* Select a resource available in CSV or JSON format
* Retrieve at least 100 records using `datastore_search`
* Convert the results into a Pandas DataFrame
* Save the DataFrame to a `.csv` file

---

## Technologies Used

* Python 3
* Pandas
* Requests
* Jupyter Notebook
* JSONPlaceholder API
* Public APIs (free tier)
* Open Data BCN — CKAN API

---

## Key Skills Demonstrated

* REST API consumption (GET, POST, PATCH, DELETE)
* HTTP status code handling
* JSON parsing and data extraction
* Dataset search and filtering
* Data wrangling with Pandas
* CSV export

---

## API Reference — Level 3

Base URL: `https://opendata-ajuntament.barcelona.cat/data/api/3/action/`

| Endpoint | Description |
|---|---|
| `package_list` | Full list of dataset names |
| `package_search?q=keyword` | Search datasets by keyword |
| `package_show?id=name` | Details and resources of a dataset |
| `datastore_search` | Query tabular data by resource ID |

More info: https://opendata-ajuntament.barcelona.cat/ca/desenvolupadors#APIS

---

## Learning Context

This project was developed as part of the **Data Analytics training program at IT Academy — Barcelona Activa**.  
Level: Beginner → Intermediate Data Analysis

---

## Author

**vbujaldon**
