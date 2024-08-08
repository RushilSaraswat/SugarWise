# Run this code if you do not have access to Gemini API or Endpoint
# This code gives mock recommendations in place of gemini
# This code does not consult Gemini due to unavailability of Endpoint or API, rather, it simply sends the data to doctor, stores it in a file and gives general recommendations.
using HTTP
using JSON
using SMTPClient
using Dates

const DATA_FILE = "patient_data.txt" # Rename this file according as per your choice

function get_gemini_recommendations(data)
    blood_sugar = data["blood_sugar"]
    if blood_sugar > 140
        recommendations = println(
            "recommendations" => [
                "Adjust your insulin dosage.",
                "Increase physical activity.",
                "Monitor your blood sugar levels more frequently."
            ])
            println(
            "consult_advice" => "Based on the data, the patient should consult a doctor.")
            println(
            "data_trend" => "The patient's blood sugar levels have been consistently high over the last few measurements.")
            println(
            "health_risks" => "The patient is at risk of developing cardiovascular diseases due to high blood sugar levels.")
        
    else
        recommendations = println(
            "recommendations" => [
                "Mantain your insulin dosage (if any)",
                "Current level of physical activity is satisfactory",
                "Blood sugar levels are satisfactory."]
        )
            println("consult_advice" => "Based on the data, consultation with a doctor is optional.")
            println("data_trend" => "The patient's blood sugar levels are within healthy range.")
            println("health_risks" => "The patient's risk of developing cardiovascular diseases is low.")
        
    end
    return recommendations
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

    println("Enter your blood sugar level(mg/dl):")
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
    
    recommendations = get_gemini_recommendations(data)
    println("Recommendations: ", recommendations)
    println(last_50_lines)

    

   

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

    
    """

    send_email("$name Diabetes Patient Data", email_content, "doctor_email@example.com") # Replace doctor_email@example.com with the doctor's email
    println("Data and recommendations sent to the doctor.")
end

collect_and_process_data()
