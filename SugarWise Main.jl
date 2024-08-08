using HTTP
using JSON
using SMTPClient
using Dates

const DATA_FILE = "patient_data.txt" # Rename this file according as per your choice

function ask_gemini_doctor_visit(data)
    url = "https://api.gemini.com/v1/doctor_visit_recommendation" # Replace this with your Gemini endpoint
    headers = ["Authorization" => "Bearer YOUR_GEMINI_API_KEY"] # Replace YOUR_GEMINI_API_KEY with your Gemini API key

    response = HTTP.post(url, headers; body = JSON.json(data))
    if response.status == 200
        recommendation = JSON.parse(String(response.body))
        return recommendation["should_visit"], recommendation["reason"], recommendation["additional_recommendations"]
    else
        error("Failed to get doctor visit recommendation: ", response.status)
    end
end


function send_email(subject, content, recipient_email)
    server = "smtp.gmail.com"
    port = 587
    username = "your_email@gmail.com" # Replace with your email (creating a mock email for this code is recommended)
    password = "your_email_password" # Replace with your email's password (creating a mock email for this code is recommended)

    client = SMTPClient.Client(server, username, password; port=port, starttls=true)

    email = SMTPClient.Message(
        from = "your_email@gmail.com", # Replace with your email (creating a mock email for this code is recommended)
        to = recipient_email,
        subject = subject,
        body = content
    )

    SMTPClient.send(client, email)
end

function write_to_file(data)
    open(DATA_FILE, "a") do file
        timestamp = Dates.now()
        line = "Timestamp: $(timestamp); Blood Sugar $(data["blood_sugar"]); Ongoing medications $(join(data["medicines"],)); Age $(data["age"]); Weight $(data["weight"]); Height $(data["height"]); Sex $(data["sex"])"
        write(file, line * "\n")
    end
end

function collect_and_process_data()
    println("Enter your name:")
    name = readline()

    println("Enter your blood sugar level:")
    blood_sugar = parse(Float64, readline())
    
    println("Enter your ongoing medications (comma-separated):")
    medicines = split(readline(), ",")
    
    println("Enter your age:")
    age = parse(Int, readline())
    
    println("Enter your weight (kg):")
    weight = parse(Float64, readline())
    
    println("Enter your height (cm):")
    height = parse(Float64, readline())
    
    println("Enter your sex (M/F):")
    sex = readline()

    data = Dict(
        "name" => name,
        "blood_sugar" => blood_sugar,
        "medicines" => medicines,
        "age" => age,
        "weight" => weight,
        "height" => height,
        "sex" => sex
    )

    write_to_file(data)
    
    # Collect the last 50 lines of data
    last_50_lines = read_last_lines(50)
    
    # Convert last 50 lines into the format expected by Gemini API
    data_for_gemini = Dict(
        "current_data" => data,
        "patient_history_data" => last_50_lines
    )
    
    recommendations = get_gemini_recommendations(data_for_gemini)
    println("Recommendations: ", recommendations)

    should_visit, reason = should_see_doctor(data_for_gemini)

    doctor_recommendation = if should_visit
        "It is recommended that you see a doctor. Reason: $reason"
    else
        "Based on your current data, you don't need to see a doctor immediately. However, keep monitoring your condition."
    end

    println(doctor_recommendation)

    email_content = """
    Patient Data:
    Name: $name
    Blood Sugar: $blood_sugar
    Medicines: $(join(medicines, ", "))
    Age: $age
    Weight: $weight
    Height: $height
    Sex: $sex

    Data:
    $last_n_lines

    Recommendations:
    $recommendations

    Doctor Visit Recommendation:
    $doctor_recommendation
    """

    send_email("$name Diabetes Patient Data", email_content, "doctor_email@example.com") # Replace doctor_email@example.com with the doctor's email
    println("Data and recommendations sent to the doctor.")
end

collect_and_process_data()
