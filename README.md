ReadMe

Patient Health Data Collection and Recommendation System

This application collects a patient's health data, retrieves recommendations from the Gemini API, determines if a doctor visit is necessary, and emails the data and recommendations to a specified doctor.


Features

-->Collects patient information including blood sugar level, ongoing medications, age, weight, height, and sex.

-->Stores the data in a text file.

-->Retrieves the last 50 lines of the stored data.

-->Sends the collected data to the Gemini API for recommendations.

-->Determines if a doctor visit is necessary based on the API's response.

-->Emails the collected data, recommendations, and doctor visit suggestion to a specified doctor.


Prerequisites

-->Julia programming language installed.

-->HTTP, JSON, SMTPClient, and Dates Julia packages installed.

-->Valid Gemini API key.

-->Valid Gmail credentials for sending emails.



Installation

Install Julia from the official website: [Julia Downloads.](https://julialang.org/)



Install the required Julia packages:

julia>

using Pkg

Pkg.add("HTTP")

Pkg.add("JSON")

Pkg.add("SMTPClient")

Pkg.add("Dates")



Replace placeholder values in the script:

https://api.gemini.com/v1/doctor_visit_recommendation with your gemini endpoint

YOUR_GEMINI_API_KEY with your actual Gemini API key.

your_email@gmail.com with your Gmail address.

your_email_password with your Gmail password.

doctor_email@example.com with the recipient doctor's email address.



Usage

Save the script to a file, e.g., Sugarwise.jl.

Run the script using the Julia interpreter:

julia> SugarWise.jl



Follow the prompts to enter the patient's data.

The script will collect and store the data, retrieve recommendations, and send an email to the specified doctor.
