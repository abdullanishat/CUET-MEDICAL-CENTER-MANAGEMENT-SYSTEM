# 🏥 CUET Medical Center Management System

A comprehensive **Bash shell script-based** medical center management system designed for educational institutions. This system provides complete management of medical services including appointments, prescriptions, ambulance requests, and more.

## 📋 Table of Contents
- [Features](#features)
- [System Requirements](#system-requirements)
- [Installation](#installation)
- [Usage](#usage)
- [User Roles](#user-roles)
- [Database Structure](#database-structure)
- [Screenshots](#screenshots)
- [Contributing](#contributing)
- [License](#license)

## ✨ Features

### 👨‍💼 Admin Features
- **User Management**
  - Register and approve students, doctors, and admins
  - View and manage pending registrations
  - Approve/reject user accounts
  
- **Appointment Management**
  - View all appointments
  - Approve/reject appointment requests
  
- **Resource Management**
  - Manage lab tests (add, view, remove)
  - Manage medicines (add, update status, remove)
  - Manage medical equipment (add, update availability, remove)
  - Manage doctor availability status
  
- **Request Handling**
  - View and process ambulance requests
  - View and process medicine requests
  
- **Feedback System**
  - View student feedback
  - Reply to feedback

### 👨‍🎓 Student (Patient) Features
- **Account Management**
  - Self-registration with OTP verification
  - Wait for admin approval
  
- **Medical Services**
  - Book appointments with available doctors
  - View appointment history and status
  - Request ambulance services
  - Request medicines (with/without prescription)
  - View prescribed medications
  - View available lab tests
  
- **Communication**
  - Submit feedback
  - View feedback and admin replies

### 👨‍⚕️ Doctor Features
- **Appointment Management**
  - View appointments with patients
  - Access patient information
  
- **Medical Records**
  - Give prescriptions to patients
  - Track prescription history

## 🖥️ System Requirements

- **Operating System**: macOS or Linux
- **Shell**: Bash (version 4.0 or higher)
- **Permissions**: Read/write access to project directory

## 📥 Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/abdullanishat/CUET-MEDICAL-CENTER-MANAGEMENT-SYSTEM.git
   cd cuet-medical-center
   ```

2. **Make the script executable**
   ```bash
   chmod +x main.sh
   ```

3. **Run the system**
   ```bash
   ./main.sh
   ```

## 🚀 Usage

### First Time Setup
The system will automatically:
- Create all necessary database files
- Generate a default admin account:
  - **Email**: `admin@cuet.edu`
  - **Password**: `admin123`

### Main Menu Options
```
1. Admin Login
2. Patient (Student) Login
3. Doctor Login
4. Register (Patient/Doctor)
5. Exit
```

### Registration Process
1. Select option 4 (Register)
2. Enter your details:
   - Name
   - Email
   - Role (Patient/Doctor)
   - Password
   - Role-specific information (Student ID or Specialization)
3. Complete OTP verification
4. Wait for admin approval

## 👥 User Roles

### 🔐 Admin
- Full system access
- User approval authority
- Resource management
- Request processing

### 👨‍🎓 Student/Patient
- Book appointments
- Request services
- View medical records
- Provide feedback

### 👨‍⚕️ Doctor
- View appointments
- Prescribe medications
- Manage patient care

## 📊 Database Structure

The system uses pipe-delimited text files for data storage:

### Core Database Files

| File | Format | Description |
|------|--------|-------------|
| `admin.txt` | Email\|Password\|Status | Admin credentials |
| `student.txt` | Email\|Password\|Role\|StudentID\|Status\|Name | Student records |
| `doctor.txt` | Email\|Password\|Name\|Specialization\|Status\|DoctorStatus | Doctor profiles |
| `appointments.txt` | StudentID\|DoctorName\|Date\|Status | Appointment records |
| `prescriptions.txt` | StudentID\|DoctorName\|Prescription\|Date | Prescription records |
| `ambulance.txt` | StudentID\|Reason\|Status | Ambulance requests |
| `medicine_requests.txt` | StudentID\|Medicine\|HasPrescription\|Status\|Date | Medicine requests |
| `feedback.txt` | StudentID\|Feedback\|Date\|AdminReply | Feedback system |
| `lab_tests.txt` | TestName\|Cost | Available lab tests |
| `equipment.txt` | EquipmentName\|Quantity\|Status | Medical equipment |
| `medicines.txt` | MedicineName\|Price\|Status | Medicine inventory |

### Status Values
- **User Status**: `Pending`, `Approved`, `Rejected`
- **Request Status**: `Pending`, `Approved`, `Rejected`
- **Doctor Status**: `Available`, `Unavailable`
- **Equipment/Medicine Status**: `Available`, `Unavailable`, `Out of Stock`

## 🎯 Key Features Explained

### 🔒 Security
- Password-protected accounts
- Role-based access control
- OTP verification during registration
- Admin approval required for new accounts

### 📅 Appointment System
- View available doctors with specializations
- Select doctor and date
- Admin approval workflow
- Duplicate prevention

### 💊 Medicine Management
- Prescription tracking (Yes/No)
- Admin approval required
- Status tracking

### 🚑 Ambulance Service
- Emergency request system
- Reason logging
- Admin approval process

### 💬 Feedback System
- Student feedback submission
- Admin reply capability
- Two-way communication

### 🔄 Data Validation
- Empty field checks
- Duplicate prevention
- Numeric validation
- Status restrictions

## 📸 Screenshots

```
╔════════════════════════════════════════════════════════════╗
║          CUET MEDICAL CENTER MANAGEMENT SYSTEM             ║
╚════════════════════════════════════════════════════════════╝

Please select an option:

1. Admin Login
2. Patient (Student) Login
3. Doctor Login
4. Register (Patient/Doctor)
5. Exit
```

## Technical Details

### Architecture
- **Language**: Bash Shell Script
- **Database**: Text files (pipe-delimited)
- **Authentication**: Email/Password based
- **Session Management**: Global variables

### Design Patterns
- Modular function design
- Menu-driven interface
- Loop-based navigation
- Input validation

### File Operations
- `grep` - Search operations
- `sed` - Update operations
- `awk` - Data parsing
- `cut` - Field extraction

## Contributing

Contributions are welcome! Please follow these steps:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

### Coding Guidelines
- Use meaningful variable names
- Add comments for complex logic
- Follow existing code style
- Test thoroughly before submitting

## Known Issues

- Manual database file cleanup required if tests fail
- Limited to single concurrent user (no multi-user support)
- No data encryption (suitable for educational purposes only)

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- Inspired by real-world medical center management needs
- Built for educational purposes
- CUET (Chittagong University of Engineering & Technology)

