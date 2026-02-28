#!/bin/bash

# ========================================
# CUET MEDICAL CENTER MANAGEMENT SYSTEM
# ========================================

# Database Files
ADMIN_DB="admin.txt"
STUDENT_DB="student.txt"
DOCTOR_DB="doctor.txt"
APPOINTMENT_DB="appointments.txt"
AMBULANCE_DB="ambulance.txt"
MEDICINE_REQUEST_DB="medicine_requests.txt"
FEEDBACK_DB="feedback.txt"
PRESCRIPTION_DB="prescriptions.txt"
LAB_TESTS_DB="lab_tests.txt"
EQUIPMENT_DB="equipment.txt"
MEDICINE_DB="medicines.txt"

# Global Variables
CURRENT_USER=""
CURRENT_ROLE=""
CURRENT_SID=""
CURRENT_NAME=""

# Initialize database files
initialize_databases() {
    # Create database files if they don't exist
    touch $ADMIN_DB $STUDENT_DB $DOCTOR_DB $APPOINTMENT_DB $AMBULANCE_DB
    touch $MEDICINE_REQUEST_DB $FEEDBACK_DB $PRESCRIPTION_DB $LAB_TESTS_DB
    touch $EQUIPMENT_DB $MEDICINE_DB
    
    # Create default admin only if admin.txt is empty
    if [ ! -s $ADMIN_DB ]; then
        echo "admin@cuet.edu|admin123|Approved" >> $ADMIN_DB
    fi
}

# Header function
header() {
    clear
    echo "╔════════════════════════════════════════════════════════════╗"
    echo "║          CUET MEDICAL CENTER MANAGEMENT SYSTEM             ║"
    echo "╚════════════════════════════════════════════════════════════╝"
    echo ""
}

# Pause function
pause_function() {
    read -p "Press Enter to continue..."
}

# ==================== AUTHENTICATION ====================

# Register User (Public registration)
register_user() {
    header
    echo "=== User Registration ==="
    read -p "Name: " name
    read -p "Email: " email
    
    echo "Select Role:"
    echo "1. Patient (Student)"
    echo "2. Doctor"
    read -p "Choice: " role_choice
    
    case $role_choice in
        1) role="patient" ;;
        2) role="doctor" ;;
        *) 
            echo "❌ Invalid choice!"
            pause_function
            return
            ;;
    esac
    
    read -s -p "Password: " password
    echo ""
    
    if [ -z "$name" ] || [ -z "$email" ] || [ -z "$password" ]; then
        echo "❌ All fields are required!"
        pause_function
        return
    fi
    
    # Check if email exists in appropriate database
    if [ "$role" = "patient" ]; then
        if grep -q "^$email|" $STUDENT_DB; then
            echo "❌ Email already registered!"
            pause_function
            return
        fi
        read -p "Student ID: " sid
        
        if [ -z "$sid" ]; then
            echo "❌ Student ID is required!"
            pause_function
            return
        fi
    elif [ "$role" = "doctor" ]; then
        if grep -q "^$email|" $DOCTOR_DB; then
            echo "❌ Email already registered!"
            pause_function
            return
        fi
        read -p "Specialization: " specialization
        
        if [ -z "$specialization" ]; then
            echo "❌ Specialization is required!"
            pause_function
            return
        fi
    fi
    
    # Generate OTP for verification
    otp=$((RANDOM % 9000 + 1000))
    echo "📧 Verification code sent to $email: $otp"
    read -p "Enter verification code: " user_otp
    
    if [ "$otp" != "$user_otp" ]; then
        echo "❌ Verification failed!"
        pause_function
        return
    fi
    
    # Add user with Pending status
    if [ "$role" = "patient" ]; then
        echo "$email|$password|patient|$sid|Pending|$name" >> $STUDENT_DB
    else
        echo "$email|$password|$name|$specialization|Pending|Available" >> $DOCTOR_DB
    fi
    
    echo "✅ Registration successful! Wait for Admin approval."
    pause_function
}

# Login User
login_user() {
    local role_expected=$1
    header
    echo "=== $role_expected Login ==="
    
    read -p "Email: " email
    read -s -p "Password: " password
    echo ""
    
    if [ -z "$email" ] || [ -z "$password" ]; then
        echo "❌ Email and password are required!"
        pause_function
        return
    fi
    
    # Find user in appropriate database
    case $role_expected in
        admin)
            user_record=$(grep "^$email|$password|Approved$" $ADMIN_DB)
            if [ -z "$user_record" ]; then
                echo "❌ Invalid credentials or not approved!"
                pause_function
                return
            fi
            CURRENT_USER=$email
            CURRENT_ROLE="admin"
            admin_menu
            ;;
        patient)
            # Search for the email|password combination
            user_record=$(grep "^$email|$password|patient|" $STUDENT_DB)
            if [ -z "$user_record" ]; then
                echo "❌ Invalid credentials!"
                pause_function
                return
            fi
            status=$(echo "$user_record" | cut -d'|' -f5)
            if [ "$status" != "Approved" ]; then
                echo "❌ Account not approved by Admin yet!"
                pause_function
                return
            fi
            CURRENT_USER=$email
            CURRENT_ROLE="patient"
            CURRENT_SID=$(echo "$user_record" | cut -d'|' -f4)
            CURRENT_NAME=$(echo "$user_record" | cut -d'|' -f6)
            student_menu
            ;;
        doctor)
            # Search for the email|password combination in doctor database
            user_record=$(grep "^$email|$password|" $DOCTOR_DB)
            if [ -z "$user_record" ]; then
                echo "❌ Invalid credentials!"
                pause_function
                return
            fi
            status=$(echo "$user_record" | cut -d'|' -f5)
            if [ "$status" != "Approved" ]; then
                echo "❌ Account not approved by Admin yet!"
                pause_function
                return
            fi
            CURRENT_USER=$email
            CURRENT_ROLE="doctor"
            CURRENT_NAME=$(echo "$user_record" | cut -d'|' -f3)
            doctor_menu
            ;;
        *)
            echo "❌ Invalid role!"
            pause_function
            ;;
    esac
}

# ==================== ADMIN FUNCTIONS ====================

admin_menu() {
    while true; do
        header
        echo "=== Admin Menu ==="
        echo "1. Register User"
        echo "2. Approve Students"
        echo "3. Approve Doctors"
        echo "4. View Appointments"
        echo "5. Manage Ambulance Requests"
        echo "6. Manage Medicine Requests"
        echo "7. View Student Feedback"
        echo "8. Manage Lab Tests"
        echo "9. Manage Equipment"
        echo "10. Manage Doctors"
        echo "11. Manage Medicines"
        echo "12. Logout"
        read -p "Choice: " ch
        
        case $ch in
            1) admin_register_user ;;
            2) admin_approve_students ;;
            3) admin_approve_doctors ;;
            4) admin_view_appointments ;;
            5) admin_view_ambulance_requests ;;
            6) admin_view_medicine_requests ;;
            7) admin_view_feedback ;;
            8) admin_manage_lab_tests ;;
            9) admin_manage_equipment ;;
            10) admin_manage_doctors ;;
            11) admin_manage_medicines ;;
            12) break ;;
            *) echo "❌ Invalid choice"; pause_function ;;
        esac
    done
}

# ==================== ADMIN FUNCTIONS ====================

admin_register_user() {
    header
    echo "=== Admin: Register User ==="
    read -p "Name: " name
    read -p "Email: " email
    read -s -p "Password: " password
    echo ""
    
    if [ -z "$name" ] || [ -z "$email" ] || [ -z "$password" ]; then
        echo "❌ All fields are required!"
        pause_function
        return
    fi
    
    echo "Select Role:"
    echo "1. Patient (Student)"
    echo "2. Doctor"
    echo "3. Admin"
    read -p "Choice: " ch
    
    case $ch in
        1)
            # Check if student email exists
            if grep -q "^$email|" $STUDENT_DB; then
                echo "❌ Email already registered!"
                pause_function
                return
            fi
            read -p "Student ID: " sid
            if [ -z "$sid" ]; then
                echo "❌ Student ID is required!"
                pause_function
                return
            fi
            echo "$email|$password|patient|$sid|Approved|$name" >> $STUDENT_DB
            echo "✅ Student registered and approved successfully!"
            ;;
        2)
            # Check if doctor email exists
            if grep -q "^$email|" $DOCTOR_DB; then
                echo "❌ Email already registered!"
                pause_function
                return
            fi
            read -p "Specialization: " specialization
            if [ -z "$specialization" ]; then
                echo "❌ Specialization is required!"
                pause_function
                return
            fi
            echo "$email|$password|$name|$specialization|Approved|Available" >> $DOCTOR_DB
            echo "✅ Doctor registered and approved successfully!"
            ;;
        3)
            # Check if admin email exists
            if grep -q "^$email|" $ADMIN_DB; then
                echo "❌ Email already registered!"
                pause_function
                return
            fi
            echo "$email|$password|Approved" >> $ADMIN_DB
            echo "✅ Admin registered successfully!"
            ;;
        *)
            echo "❌ Invalid role"
            pause_function
            return
            ;;
    esac
    
    pause_function
}

admin_approve_students() {
    while true; do
        header
        echo "=== Approve Students ==="
        echo "1. View Pending Students"
        echo "2. Approve/Reject Student"
        echo "3. Back to Admin Menu"
        read -p "Choice: " ch
        
        case $ch in
            1)
                header
                echo "=== Pending Students ==="
                if grep -q "Pending" $STUDENT_DB; then
                    echo "Email | Student ID | Name"
                    echo "-----------------------------------"
                    grep "|Pending|" $STUDENT_DB | awk -F'|' '{print $1 " | " $4 " | " $6}' | nl
                else
                    echo "No pending students!"
                fi
                pause_function
                ;;
            2)
                header
                echo "Pending Students:"
                pending_list=$(grep "|Pending|" $STUDENT_DB)
                if [ -z "$pending_list" ]; then
                    echo "No pending students!"
                else
                    echo "$pending_list" | awk -F'|' '{print $1 " | " $4 " | " $6}' | nl
                    read -p "Enter student number: " line_num
                    
                    if [ -z "$line_num" ] || ! [[ "$line_num" =~ ^[0-9]+$ ]]; then
                        echo "❌ Please enter a valid student number!"
                    else
                        # Get the email from the line number
                        student_email=$(echo "$pending_list" | sed -n "${line_num}p" | cut -d'|' -f1)
                        
                        if [ -z "$student_email" ]; then
                            echo "❌ Student not found!"
                        else
                            echo "1. Approve"
                            echo "2. Reject"
                            read -p "Choice: " action
                            
                            case $action in
                                1)
                                    sed -i "" "s/^$student_email|\(.*\)|Pending|/$student_email|\1|Approved|/g" $STUDENT_DB
                                    echo "✅ Student approved!"
                                    ;;
                                2)
                                    sed -i "" "s/^$student_email|\(.*\)|Pending|/$student_email|\1|Rejected|/g" $STUDENT_DB
                                    echo "✅ Student rejected!"
                                    ;;
                                *)
                                    echo "❌ Invalid choice"
                                    ;;
                            esac
                        fi
                    fi
                fi
                pause_function
                ;;
            3)
                break
                ;;
            *)
                echo "❌ Invalid choice"
                pause_function
                ;;
        esac
    done
}

admin_approve_doctors() {
    while true; do
        header
        echo "=== Approve Doctors ==="
        echo "1. View Pending Doctors"
        echo "2. Approve/Reject Doctor"
        echo "3. Back to Admin Menu"
        read -p "Choice: " ch
        
        case $ch in
            1)
                header
                echo "=== Pending Doctors ==="
                if grep -q "Pending" $DOCTOR_DB; then
                    echo "Email | Name | Specialization"
                    echo "-----------------------------------"
                    grep "|Pending|" $DOCTOR_DB | awk -F'|' '{print $1 " | " $3 " | " $4}' | nl
                else
                    echo "No pending doctors!"
                fi
                pause_function
                ;;
            2)
                header
                echo "Pending Doctors:"
                pending_list=$(grep "|Pending|" $DOCTOR_DB)
                if [ -z "$pending_list" ]; then
                    echo "No pending doctors!"
                else
                    echo "$pending_list" | awk -F'|' '{print $1 " | " $3 " | " $4}' | nl
                    read -p "Enter doctor number: " line_num
                    
                    if [ -z "$line_num" ] || ! [[ "$line_num" =~ ^[0-9]+$ ]]; then
                        echo "❌ Please enter a valid doctor number!"
                    else
                        # Get the email from the line number
                        doctor_email=$(echo "$pending_list" | sed -n "${line_num}p" | cut -d'|' -f1)
                        
                        if [ -z "$doctor_email" ]; then
                            echo "❌ Doctor not found!"
                        else
                            echo "1. Approve"
                            echo "2. Reject"
                            read -p "Choice: " action
                            
                            case $action in
                                1)
                                    sed -i "" "s/^$doctor_email|\(.*\)|Pending|/$doctor_email|\1|Approved|/g" $DOCTOR_DB
                                    echo "✅ Doctor approved!"
                                    ;;
                                2)
                                    sed -i "" "s/^$doctor_email|\(.*\)|Pending|/$doctor_email|\1|Rejected|/g" $DOCTOR_DB
                                    echo "✅ Doctor rejected!"
                                    ;;
                                *)
                                    echo "❌ Invalid choice"
                                    ;;
                            esac
                        fi
                    fi
                fi
                pause_function
                ;;
            3)
                break
                ;;
            *)
                echo "❌ Invalid choice"
                pause_function
                ;;
        esac
    done
}

admin_view_appointments() {
    while true; do
        header
        echo "=== Manage Appointments ==="
        echo "1. View All Appointments"
        echo "2. Accept/Reject Appointment"
        echo "3. Back to Admin Menu"
        read -p "Choice: " ch
        
        case $ch in
            1)
                header
                echo "=== All Appointments ==="
                if [ ! -s $APPOINTMENT_DB ]; then
                    echo "No appointments found!"
                else
                    echo "Student ID | Doctor Name | Date | Status"
                    echo "-----------------------------------------------------"
                    cat $APPOINTMENT_DB | nl
                fi
                pause_function
                ;;
            2)
                header
                echo "Pending Appointments:"
                pending_list=$(grep "|Pending" $APPOINTMENT_DB)
                if [ -z "$pending_list" ]; then
                    echo "No pending appointments!"
                else
                    echo "$pending_list" | nl
                    read -p "Enter line number: " line_num
                    
                    if [ -z "$line_num" ] || ! [[ "$line_num" =~ ^[0-9]+$ ]]; then
                        echo "❌ Please enter a valid number!"
                    else
                        # Get the appointment record from pending list
                        appointment_record=$(echo "$pending_list" | sed -n "${line_num}p")
                        
                        if [ -z "$appointment_record" ]; then
                            echo "❌ Appointment not found!"
                        else
                            # Extract student ID and doctor name to create unique identifier
                            sid=$(echo "$appointment_record" | cut -d'|' -f1)
                            doc_name=$(echo "$appointment_record" | cut -d'|' -f2)
                            date=$(echo "$appointment_record" | cut -d'|' -f3)
                            
                            echo "1. Accept"
                            echo "2. Reject"
                            read -p "Choice: " action
                            
                            case $action in
                                1)
                                    # Replace Pending with Approved for this specific appointment
                                    sed -i "" "s/^$sid|$doc_name|$date|Pending/$sid|$doc_name|$date|Approved/" $APPOINTMENT_DB
                                    echo "✅ Appointment accepted!"
                                    ;;
                                2)
                                    # Replace Pending with Rejected for this specific appointment
                                    sed -i "" "s/^$sid|$doc_name|$date|Pending/$sid|$doc_name|$date|Rejected/" $APPOINTMENT_DB
                                    echo "✅ Appointment rejected!"
                                    ;;
                                *)
                                    echo "❌ Invalid choice"
                                    ;;
                            esac
                        fi
                    fi
                fi
                pause_function
                ;;
            3)
                break
                ;;
            *)
                echo "❌ Invalid choice"
                pause_function
                ;;
        esac
    done
}

admin_view_ambulance_requests() {
    while true; do
        header
        echo "=== Manage Ambulance Requests ==="
        echo "1. View All Requests"
        echo "2. Accept/Reject Request"
        echo "3. Back to Admin Menu"
        read -p "Choice: " ch
        
        case $ch in
            1)
                header
                echo "=== All Ambulance Requests ==="
                if [ ! -s $AMBULANCE_DB ]; then
                    echo "No requests found!"
                else
                    echo "Student ID | Reason | Status"
                    echo "------------------------------"
                    cat $AMBULANCE_DB | nl
                fi
                pause_function
                ;;
            2)
                header
                echo "Pending Requests:"
                pending_list=$(grep "|Pending" $AMBULANCE_DB)
                if [ -z "$pending_list" ]; then
                    echo "No pending requests!"
                else
                    echo "$pending_list" | nl
                    read -p "Enter line number: " line_num
                    
                    if [ -z "$line_num" ] || ! [[ "$line_num" =~ ^[0-9]+$ ]]; then
                        echo "❌ Please enter a valid number!"
                    else
                        # Get the request record from pending list
                        request_record=$(echo "$pending_list" | sed -n "${line_num}p")
                        
                        if [ -z "$request_record" ]; then
                            echo "❌ Request not found!"
                        else
                            # Extract student ID and reason to create unique identifier
                            sid=$(echo "$request_record" | cut -d'|' -f1)
                            reason=$(echo "$request_record" | cut -d'|' -f2)
                            
                            echo "1. Accept"
                            echo "2. Reject"
                            read -p "Choice: " action
                            
                            case $action in
                                1)
                                    # Replace Pending with Approved for this specific request
                                    sed -i "" "s/^$sid|$reason|Pending/$sid|$reason|Approved/" $AMBULANCE_DB
                                    echo "✅ Request accepted!"
                                    ;;
                                2)
                                    # Replace Pending with Rejected for this specific request
                                    sed -i "" "s/^$sid|$reason|Pending/$sid|$reason|Rejected/" $AMBULANCE_DB
                                    echo "✅ Request rejected!"
                                    ;;
                                *)
                                    echo "❌ Invalid choice"
                                    ;;
                            esac
                        fi
                    fi
                fi
                pause_function
                ;;
            3)
                break
                ;;
            *)
                echo "❌ Invalid choice"
                pause_function
                ;;
        esac
    done
}

admin_view_medicine_requests() {
    while true; do
        header
        echo "=== Manage Medicine Requests ==="
        echo "1. View All Requests"
        echo "2. Accept/Reject Request"
        echo "3. Back to Admin Menu"
        read -p "Choice: " ch
        
        case $ch in
            1)
                header
                echo "=== All Medicine Requests ==="
                if [ ! -s $MEDICINE_REQUEST_DB ]; then
                    echo "No requests found!"
                else
                    echo "Student ID | Medicine | Has Prescription | Status | Date"
                    echo "---------------------------------------------------------------------"
                    cat $MEDICINE_REQUEST_DB | nl
                fi
                pause_function
                ;;
            2)
                header
                echo "Pending Requests:"
                pending_list=$(grep "|Pending" $MEDICINE_REQUEST_DB)
                if [ -z "$pending_list" ]; then
                    echo "No pending requests!"
                else
                    echo "$pending_list" | nl
                    read -p "Enter line number: " line_num
                    
                    if [ -z "$line_num" ] || ! [[ "$line_num" =~ ^[0-9]+$ ]]; then
                        echo "❌ Please enter a valid number!"
                    else
                        # Get the request record from pending list
                        request_record=$(echo "$pending_list" | sed -n "${line_num}p")
                        
                        if [ -z "$request_record" ]; then
                            echo "❌ Request not found!"
                        else
                            # Extract student ID, medicine, has_prescription, and timestamp
                            sid=$(echo "$request_record" | cut -d'|' -f1)
                            medicine=$(echo "$request_record" | cut -d'|' -f2)
                            has_prescription=$(echo "$request_record" | cut -d'|' -f3)
                            timestamp=$(echo "$request_record" | cut -d'|' -f5)
                            
                            echo "1. Accept"
                            echo "2. Reject"
                            read -p "Choice: " action
                            
                            case $action in
                                1)
                                    # Replace Pending with Approved for this specific request
                                    sed -i "" "s/^$sid|$medicine|$has_prescription|Pending|$timestamp/$sid|$medicine|$has_prescription|Approved|$timestamp/" $MEDICINE_REQUEST_DB
                                    echo "✅ Request accepted!"
                                    ;;
                                2)
                                    # Replace Pending with Rejected for this specific request
                                    sed -i "" "s/^$sid|$medicine|$has_prescription|Pending|$timestamp/$sid|$medicine|$has_prescription|Rejected|$timestamp/" $MEDICINE_REQUEST_DB
                                    echo "✅ Request rejected!"
                                    ;;
                                *)
                                    echo "❌ Invalid choice"
                                    ;;
                            esac
                        fi
                    fi
                fi
                pause_function
                ;;
            3)
                break
                ;;
            *)
                echo "❌ Invalid choice"
                pause_function
                ;;
        esac
    done
}

admin_view_feedback() {
    while true; do
        header
        echo "=== Manage Student Feedback ==="
        echo "1. View All Feedback"
        echo "2. Reply to Feedback"
        echo "3. Back to Admin Menu"
        read -p "Choice: " ch
        
        case $ch in
            1)
                header
                echo "=== All Student Feedback ==="
                if [ ! -s $FEEDBACK_DB ]; then
                    echo "No feedback found!"
                else
                    echo "Student ID | Feedback | Date | Reply"
                    echo "-----------------------------------------------------------"
                    grep -v "^$" $FEEDBACK_DB | nl
                fi
                pause_function
                ;;
            2)
                header
                echo "=== Reply to Feedback ==="
                if [ ! -s $FEEDBACK_DB ]; then
                    echo "No feedback found!"
                else
                    echo "Student ID | Feedback | Date | Reply"
                    echo "-----------------------------------------------------------"
                    # Filter out empty lines and display
                    feedback_list=$(grep -v "^$" $FEEDBACK_DB)
                    if [ -z "$feedback_list" ]; then
                        echo "No feedback found!"
                    else
                        echo "$feedback_list" | nl
                        echo ""
                        read -p "Enter feedback number to reply: " fb_num
                        
                        if [ -z "$fb_num" ] || ! [[ "$fb_num" =~ ^[0-9]+$ ]]; then
                            echo "❌ Please enter a valid number!"
                        else
                            # Get the feedback record from filtered list
                            feedback_record=$(echo "$feedback_list" | sed -n "${fb_num}p")
                            
                            if [ -z "$feedback_record" ]; then
                                echo "❌ Feedback not found!"
                            else
                            # Extract components
                            sid=$(echo "$feedback_record" | cut -d'|' -f1)
                            feedback_text=$(echo "$feedback_record" | cut -d'|' -f2)
                            date_value=$(echo "$feedback_record" | cut -d'|' -f3)
                            current_reply=$(echo "$feedback_record" | cut -d'|' -f4)
                            
                            echo ""
                            echo "Student ID: $sid"
                            echo "Feedback: $feedback_text"
                            echo "Date: $date_value"
                            if [ ! -z "$current_reply" ]; then
                                echo "Current Reply: $current_reply"
                            fi
                            echo ""
                            read -p "Enter your reply: " admin_reply
                            
                            if [ -z "$admin_reply" ]; then
                                echo "❌ Reply cannot be empty!"
                            else
                                # Create a temporary file to rebuild the database
                                temp_file="${FEEDBACK_DB}.tmp"
                                > "$temp_file"
                                
                                # Read the file line by line and update the matching record
                                while IFS='|' read -r db_sid db_feedback db_date db_reply; do
                                    if [ "$db_sid" = "$sid" ] && [ "$db_feedback" = "$feedback_text" ] && [ "$db_date" = "$date_value" ]; then
                                        # This is the record to update
                                        echo "$sid|$feedback_text|$date_value|$admin_reply" >> "$temp_file"
                                    elif [ ! -z "$db_sid" ]; then
                                        # Keep other records as-is
                                        echo "$db_sid|$db_feedback|$db_date|$db_reply" >> "$temp_file"
                                    fi
                                done < "$FEEDBACK_DB"                                    # Replace the original file with the updated one
                                    mv "$temp_file" "$FEEDBACK_DB"
                                    echo "✅ Reply added successfully!"
                                fi
                            fi
                        fi
                    fi
                fi
                pause_function
                ;;
            3)
                break
                ;;
            *)
                echo "❌ Invalid choice"
                pause_function
                ;;
        esac
    done
}

admin_manage_lab_tests() {
    while true; do
        header
        echo "=== Manage Lab Tests ==="
        echo "1. View All Tests"
        echo "2. Add New Test"
        echo "3. Remove Test"
        echo "4. Back to Admin Menu"
        read -p "Choice: " ch
        
        case $ch in
            1)
                header
                echo "=== Available Lab Tests ==="
                if [ ! -s $LAB_TESTS_DB ]; then
                    echo "No tests found!"
                else
                    echo "Test Name | Cost"
                    echo "-------------------"
                    cat $LAB_TESTS_DB | nl
                fi
                pause_function
                ;;
            2)
                header
                read -p "Test Name: " test_name
                read -p "Cost: " cost
                
                if [ -z "$test_name" ] || [ -z "$cost" ]; then
                    echo "❌ Test name and cost cannot be empty!"
                else
                    echo "$test_name|$cost" >> $LAB_TESTS_DB
                    echo "✅ Test added successfully!"
                fi
                pause_function
                ;;
            3)
                header
                echo "Available Tests:"
                cat $LAB_TESTS_DB | nl
                read -p "Enter test number to remove: " test_num
                
                if [ -z "$test_num" ] || ! [[ "$test_num" =~ ^[0-9]+$ ]]; then
                    echo "❌ Please enter a valid test number!"
                else
                    sed -i "" "${test_num}d" $LAB_TESTS_DB
                    echo "✅ Test removed successfully!"
                fi
                pause_function
                ;;
            4)
                break
                ;;
            *)
                echo "❌ Invalid choice"
                pause_function
                ;;
        esac
    done
}

admin_manage_equipment() {
    while true; do
        header
        echo "=== Manage Equipment ==="
        echo "1. View All Equipment"
        echo "2. Add Equipment"
        echo "3. Update Equipment Status"
        echo "4. Remove Equipment"
        echo "5. Back to Admin Menu"
        read -p "Choice: " ch
        
        case $ch in
            1)
                header
                echo "=== Available Equipment ==="
                if [ ! -s $EQUIPMENT_DB ]; then
                    echo "No equipment found!"
                else
                    echo "Equipment Name | Quantity | Status"
                    echo "--------------------------------------"
                    cat $EQUIPMENT_DB | nl
                fi
                pause_function
                ;;
            2)
                header
                read -p "Equipment Name: " eq_name
                read -p "Quantity: " quantity
                
                if [ -z "$eq_name" ] || [ -z "$quantity" ]; then
                    echo "❌ Equipment name and quantity cannot be empty!"
                else
                    echo "$eq_name|$quantity|Available" >> $EQUIPMENT_DB
                    echo "✅ Equipment added successfully!"
                fi
                pause_function
                ;;
            3)
                header
                echo "Equipment List:"
                cat $EQUIPMENT_DB | nl
                read -p "Enter equipment number: " eq_num
                
                if [ -z "$eq_num" ] || ! [[ "$eq_num" =~ ^[0-9]+$ ]]; then
                    echo "❌ Please enter a valid equipment number!"
                else
                    echo "Available Status:"
                    echo "1. Available"
                    echo "2. Unavailable"
                    read -p "Choose status (1 or 2): " status_choice
                    
                    if [ "$status_choice" = "1" ]; then
                        status="Available"
                    elif [ "$status_choice" = "2" ]; then
                        status="Unavailable"
                    else
                        echo "❌ Invalid status choice!"
                        pause_function
                        continue
                    fi
                    
                    local line=$(sed -n "${eq_num}p" $EQUIPMENT_DB)
                    local updated_line=$(echo "$line" | sed "s/|[^|]*$/|$status/")
                    sed -i "" "${eq_num}s/.*/$updated_line/" $EQUIPMENT_DB
                    echo "✅ Equipment updated successfully!"
                fi
                pause_function
                ;;
            4)
                header
                echo "Equipment List:"
                cat $EQUIPMENT_DB | nl
                read -p "Enter equipment number to remove: " eq_num
                
                if [ -z "$eq_num" ] || ! [[ "$eq_num" =~ ^[0-9]+$ ]]; then
                    echo "❌ Please enter a valid equipment number!"
                else
                    sed -i "" "${eq_num}d" $EQUIPMENT_DB
                    echo "✅ Equipment removed successfully!"
                fi
                pause_function
                ;;
            5)
                break
                ;;
            *)
                echo "❌ Invalid choice"
                pause_function
                ;;
        esac
    done
}

admin_manage_doctors() {
    while true; do
        header
        echo "=== Manage Doctors ==="
        echo "1. View All Doctors"
        echo "2. Update Doctor Status"
        echo "3. Remove Doctor"
        echo "4. Back to Admin Menu"
        read -p "Choice: " ch
        
        case $ch in
            1)
                header
                echo "=== Registered Doctors ==="
                if [ ! -s $DOCTOR_DB ]; then
                    echo "No doctors found!"
                else
                    echo "Email | Name | Specialization | Status"
                    echo "---------------------------------------------"
                    grep "|Approved|" $DOCTOR_DB | awk -F'|' '{print $1 " | " $3 " | " $4 " | " $6}' | nl
                fi
                pause_function
                ;;
            2)
                header
                echo "Doctors List:"
                grep "|Approved|" $DOCTOR_DB | awk -F'|' '{print $1 " | " $3 " | " $4 " | " $6}' | nl
                read -p "Enter doctor number to update: " doc_num
                
                if [ -z "$doc_num" ] || ! [[ "$doc_num" =~ ^[0-9]+$ ]]; then
                    echo "❌ Please enter a valid doctor number!"
                else
                    echo "Status Options:"
                    echo "1. Available"
                    echo "2. Unavailable"
                    read -p "Choose status (1 or 2): " status_choice
                    
                    if [ "$status_choice" = "1" ]; then
                        new_status="Available"
                    elif [ "$status_choice" = "2" ]; then
                        new_status="Unavailable"
                    else
                        echo "❌ Invalid status choice!"
                        pause_function
                        continue
                    fi
                    
                    # Get doctor line and update
                    local doc_line=$(grep "|Approved|" $DOCTOR_DB | sed -n "${doc_num}p")
                    local doc_email=$(echo "$doc_line" | cut -d'|' -f1)
                    
                    if [ -z "$doc_email" ]; then
                        echo "❌ Doctor not found!"
                    else
                        local updated_line=$(echo "$doc_line" | sed "s/|[^|]*$/|$new_status/")
                        # Use temporary file for safe update
                        sed -i "" "/^$doc_email|/c\\
$updated_line
" $DOCTOR_DB
                        echo "✅ Doctor status updated successfully!"
                    fi
                fi
                pause_function
                ;;
            3)
                header
                echo "Doctors List:"
                grep "|Approved|" $DOCTOR_DB | awk -F'|' '{print $1 " | " $3 " | " $4 " | " $6}' | nl
                read -p "Enter doctor number to remove: " doc_num
                
                if [ -z "$doc_num" ] || ! [[ "$doc_num" =~ ^[0-9]+$ ]]; then
                    echo "❌ Please enter a valid doctor number!"
                else
                    local doc_line=$(grep "|Approved|" $DOCTOR_DB | sed -n "${doc_num}p")
                    local doc_email=$(echo "$doc_line" | cut -d'|' -f1)
                    
                    if [ -z "$doc_email" ]; then
                        echo "❌ Doctor not found!"
                    else
                        sed -i "" "/^$doc_email|/d" $DOCTOR_DB
                        echo "✅ Doctor removed successfully!"
                    fi
                fi
                pause_function
                ;;
            4)
                break
                ;;
            *)
                echo "❌ Invalid choice"
                pause_function
                ;;
        esac
    done
}

admin_manage_medicines() {
    while true; do
        header
        echo "=== Manage Medicines ==="
        echo "1. View All Medicines"
        echo "2. Add Medicine"
        echo "3. Update Medicine Status"
        echo "4. Remove Medicine"
        echo "5. Back to Admin Menu"
        read -p "Choice: " ch
        
        case $ch in
            1)
                header
                echo "=== Available Medicines ==="
                if [ ! -s $MEDICINE_DB ]; then
                    echo "No medicines found!"
                else
                    echo "Medicine Name | Price | Status"
                    echo "---------------------------------"
                    cat $MEDICINE_DB | nl
                fi
                pause_function
                ;;
            2)
                header
                read -p "Medicine Name: " med_name
                read -p "Price: " price
                
                if [ -z "$med_name" ] || [ -z "$price" ]; then
                    echo "❌ Medicine name and price cannot be empty!"
                else
                    echo "$med_name|$price|Available" >> $MEDICINE_DB
                    echo "✅ Medicine added successfully!"
                fi
                pause_function
                ;;
            3)
                header
                echo "Medicines List:"
                cat $MEDICINE_DB | nl
                read -p "Enter medicine number: " med_num
                
                if [ -z "$med_num" ] || ! [[ "$med_num" =~ ^[0-9]+$ ]]; then
                    echo "❌ Please enter a valid medicine number!"
                else
                    echo "Status Options:"
                    echo "1. Available"
                    echo "2. Out of Stock"
                    read -p "Choose status (1 or 2): " status_choice
                    
                    if [ "$status_choice" = "1" ]; then
                        status="Available"
                    elif [ "$status_choice" = "2" ]; then
                        status="Out of Stock"
                    else
                        echo "❌ Invalid status choice!"
                        pause_function
                        continue
                    fi
                    
                    local line=$(sed -n "${med_num}p" $MEDICINE_DB)
                    local updated_line=$(echo "$line" | sed "s/|[^|]*$/|$status/")
                    sed -i "" "${med_num}s/.*/$updated_line/" $MEDICINE_DB
                    echo "✅ Medicine updated successfully!"
                fi
                pause_function
                ;;
            4)
                header
                echo "Medicines List:"
                cat $MEDICINE_DB | nl
                read -p "Enter medicine number to remove: " med_num
                
                if [ -z "$med_num" ] || ! [[ "$med_num" =~ ^[0-9]+$ ]]; then
                    echo "❌ Please enter a valid medicine number!"
                else
                    sed -i "" "${med_num}d" $MEDICINE_DB
                    echo "✅ Medicine removed successfully!"
                fi
                pause_function
                ;;
            5)
                break
                ;;
            *)
                echo "❌ Invalid choice"
                pause_function
                ;;
        esac
    done
}

# ==================== STUDENT FUNCTIONS ====================

student_menu() {
    while true; do
        header
        echo "=== Student Menu ==="
        echo "Welcome, $CURRENT_NAME (Student ID: $CURRENT_SID)"
        echo ""
        echo "1. Book Appointment"
        echo "2. View My Appointments"
        echo "3. Request Ambulance"
        echo "4. Request Medicine"
        echo "5. Feedback"
        echo "6. View Lab Tests"
        echo "7. View My Prescription"
        echo "8. Logout"
        read -p "Choice: " ch
        
        case $ch in
            1) student_book_appointment ;;
            2) student_view_appointments ;;
            3) student_request_ambulance ;;
            4) student_request_medicine ;;
            5) student_submit_feedback ;;
            6) student_view_lab_tests ;;
            7) student_view_prescription ;;
            8) break ;;
            *) echo "❌ Invalid choice"; pause_function ;;
        esac
    done
}

student_book_appointment() {
    header
    echo "=== Book Appointment ==="
    
    # Show available doctors
    approved_doctors=$(grep "|Approved|Available$" $DOCTOR_DB)
    
    if [ -z "$approved_doctors" ]; then
        echo "❌ No available doctors found!"
        pause_function
        return
    fi
    
    echo "Available Doctors:"
    echo "Name | Specialization"
    echo "-----------------------------------"
    echo "$approved_doctors" | awk -F'|' '{print $3 " | " $4}' | nl
    
    read -p "Enter doctor number to book appointment: " doc_num
    
    if [ -z "$doc_num" ] || ! [[ "$doc_num" =~ ^[0-9]+$ ]]; then
        echo "❌ Please enter a valid doctor number!"
        pause_function
        return
    fi
    
    # Get the doctor name and email from the selected number
    doc_record=$(echo "$approved_doctors" | sed -n "${doc_num}p")
    doc_email=$(echo "$doc_record" | cut -d'|' -f1)
    doc_name=$(echo "$doc_record" | cut -d'|' -f3)
    
    if [ -z "$doc_email" ]; then
        echo "❌ Doctor not found!"
        pause_function
        return
    fi
    
    read -p "Date (YYYY-MM-DD): " date
    
    if [ -z "$date" ]; then
        echo "❌ Date is required!"
        pause_function
        return
    fi
    
    # Check if student already has an appointment with this doctor on the same date
    if grep -q "^$CURRENT_SID|$doc_name|$date|" $APPOINTMENT_DB; then
        echo "❌ You already have an appointment with this doctor on this date!"
        pause_function
        return
    fi
    
    echo "$CURRENT_SID|$doc_name|$date|Pending" >> $APPOINTMENT_DB
    echo "✅ Appointment booked successfully!"
    pause_function
}

student_view_appointments() {
    header
    echo "=== My Appointments ==="
    if grep -q "^$CURRENT_SID|" $APPOINTMENT_DB; then
        echo "Doctor Name | Date | Status"
        echo "-------------------------------------"
        grep "^$CURRENT_SID|" $APPOINTMENT_DB | cut -d'|' -f2,3,4 | nl
    else
        echo "No appointments found!"
    fi
    pause_function
}

student_request_ambulance() {
    while true; do
        header
        echo "=== Ambulance Management ==="
        echo "1. View My Requests"
        echo "2. Request Ambulance"
        echo "3. Back to Student Menu"
        read -p "Choice: " ch
        
        case $ch in
            1)
                header
                echo "=== My Ambulance Requests ==="
                if grep -q "^$CURRENT_SID|" $AMBULANCE_DB; then
                    echo "Reason | Status"
                    echo "--------------------------------------"
                    grep "^$CURRENT_SID|" $AMBULANCE_DB | cut -d'|' -f2-3 | nl
                else
                    echo "No ambulance requests found!"
                fi
                pause_function
                ;;
            2)
                header
                echo "=== Request Ambulance ==="
                read -p "Reason: " reason
                
                if [ -z "$reason" ]; then
                    echo "❌ Reason cannot be empty!"
                else
                    echo "$CURRENT_SID|$reason|Pending" >> $AMBULANCE_DB
                    echo "✅ Ambulance request submitted!"
                fi
                pause_function
                ;;
            3)
                break
                ;;
            *)
                echo "❌ Invalid choice"
                pause_function
                ;;
        esac
    done
}

student_request_medicine() {
    while true; do
        header
        echo "=== Medicine Management ==="
        echo "1. View My Requests"
        echo "2. Request Medicine"
        echo "3. Back to Student Menu"
        read -p "Choice: " ch
        
        case $ch in
            1)
                header
                echo "=== My Medicine Requests ==="
                if grep -q "^$CURRENT_SID|" $MEDICINE_REQUEST_DB; then
                    echo "Medicine | Has Prescription | Status | Date"
                    echo "---------------------------------------------------"
                    grep "^$CURRENT_SID|" $MEDICINE_REQUEST_DB | cut -d'|' -f2,3,4,5 | nl
                else
                    echo "No medicine requests found!"
                fi
                pause_function
                ;;
            2)
                header
                echo "=== Request Medicine ==="
                read -p "Medicine Name: " medicine
                
                echo "Do you have prescription?"
                echo "1. Yes"
                echo "2. No"
                read -p "Choice: " prescription_choice
                
                case $prescription_choice in
                    1) has_prescription="Yes" ;;
                    2) has_prescription="No" ;;
                    *) 
                        echo "❌ Invalid choice!"
                        pause_function
                        return
                        ;;
                esac
                
                if [ -z "$medicine" ]; then
                    echo "❌ Medicine name is required!"
                else
                    date_only=$(date "+%Y-%m-%d")
                    echo "$CURRENT_SID|$medicine|$has_prescription|Pending|$date_only" >> $MEDICINE_REQUEST_DB
                    echo "✅ Medicine request submitted!"
                fi
                pause_function
                ;;
            3)
                break
                ;;
            *)
                echo "❌ Invalid choice"
                pause_function
                ;;
        esac
    done
}

student_submit_feedback() {
    while true; do
        header
        echo "=== Feedback Management ==="
        echo "1. View My Feedback"
        echo "2. Submit Feedback"
        echo "3. Back to Student Menu"
        read -p "Choice: " ch
        
        case $ch in
            1)
                header
                echo "=== My Feedback ==="
                if grep -q "^$CURRENT_SID|" $FEEDBACK_DB; then
                    echo "Feedback | Date | Admin Reply"
                    echo "-----------------------------------------------"
                    grep "^$CURRENT_SID|" $FEEDBACK_DB | cut -d'|' -f2-4 | nl
                else
                    echo "No feedback submitted yet!"
                fi
                pause_function
                ;;
            2)
                header
                echo "=== Submit Feedback ==="
                read -p "Your Feedback: " feedback
                
                if [ -z "$feedback" ]; then
                    echo "❌ Feedback cannot be empty!"
                else
                    date_only=$(date "+%Y-%m-%d")
                    echo "$CURRENT_SID|$feedback|$date_only|" >> $FEEDBACK_DB
                    echo "✅ Feedback submitted!"
                fi
                pause_function
                ;;
            3)
                break
                ;;
            *)
                echo "❌ Invalid choice"
                pause_function
                ;;
        esac
    done
}

student_view_feedback() {
    student_submit_feedback
}

student_view_lab_tests() {
    header
    echo "=== Available Lab Tests ==="
    if [ ! -s $LAB_TESTS_DB ]; then
        echo "No tests available!"
    else
        echo "Test Name | Cost"
        echo "-------------------"
        cat $LAB_TESTS_DB | nl
    fi
    pause_function
}

student_view_prescription() {
    header
    echo "=== My Prescription ==="
    if grep -q "^$CURRENT_SID|" $PRESCRIPTION_DB; then
        echo "Doctor Name | Prescription | Date"
        echo "-----------------------------------------------------"
        grep "^$CURRENT_SID|" $PRESCRIPTION_DB | cut -d'|' -f2-4 | nl
    else
        echo "No prescription available!"
    fi
    pause_function
}

# ==================== DOCTOR FUNCTIONS ====================

doctor_menu() {
    while true; do
        header
        echo "=== Doctor Menu ==="
        echo "Welcome, Dr. $CURRENT_NAME"
        echo ""
        echo "1. View Appointments"
        echo "2. Give Prescription"
        echo "3. Logout"
        read -p "Choice: " ch
        
        case $ch in
            1) doctor_view_appointments ;;
            2) doctor_give_prescription ;;
            3) break ;;
            *) echo "❌ Invalid choice"; pause_function ;;
        esac
    done
}

doctor_view_appointments() {
    header
    echo "=== My Appointments ==="
    # Check if doctor has any appointments (using doctor's name as CURRENT_NAME)
    if grep -q "|$CURRENT_NAME|" $APPOINTMENT_DB; then
        echo "Student ID | Date | Status"
        echo "---------------------------------------"
        grep "|$CURRENT_NAME|" $APPOINTMENT_DB | cut -d'|' -f1,3,4 | nl
    else
        echo "No appointments found!"
    fi
    pause_function
}

doctor_give_prescription() {
    header
    echo "=== Give Prescription ==="
    
    # Show doctor's appointments first (using doctor's name)
    if grep -q "|$CURRENT_NAME|" $APPOINTMENT_DB; then
        echo "Your Appointments:"
        echo "Student ID | Date | Status"
        echo "---------------------------------------"
        grep "|$CURRENT_NAME|" $APPOINTMENT_DB | cut -d'|' -f1,3,4 | nl
        echo ""
    else
        echo "No appointments found!"
        pause_function
        return
    fi
    
    read -p "Enter Student ID to prescribe: " student_id
    
    if [ -z "$student_id" ]; then
        echo "❌ Student ID is required!"
        pause_function
        return
    fi
    
    # Verify student has an appointment with this doctor (using doctor's name)
    if ! grep -q "^$student_id|$CURRENT_NAME|" $APPOINTMENT_DB; then
        echo "❌ No appointment found for this student with you!"
        pause_function
        return
    fi
    
    read -p "Prescription Details: " prescription
    
    if [ -z "$prescription" ]; then
        echo "❌ Prescription details are required!"
        pause_function
        return
    fi
    
    date_only=$(date "+%Y-%m-%d")
    echo "$student_id|$CURRENT_NAME|$prescription|$date_only" >> $PRESCRIPTION_DB
    echo "✅ Prescription given successfully!"
    pause_function
}

# ==================== MAIN MENU ====================

main_menu() {
    while true; do
        header
        echo "Please select an option:"
        echo ""
        echo "1. Admin Login"
        echo "2. Patient (Student) Login"
        echo "3. Doctor Login"
        echo "4. Register (Patient/Doctor)"
        echo "5. Exit"
        echo ""
        read -p "Choice: " ch
        
        case $ch in
            1) login_user admin ;;
            2) login_user patient ;;
            3) login_user doctor ;;
            4) register_user ;;
            5) 
                echo "Thank you for using CUET Medical Center Management System!"
                exit 0
                ;;
            *) 
                echo "❌ Invalid choice"
                pause_function
                ;;
        esac
    done
}

# ==================== MAIN EXECUTION ====================

initialize_databases
main_menu
