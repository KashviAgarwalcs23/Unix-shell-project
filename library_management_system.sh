#!/bin/bash 
# Library data files 
LIBRARY_DB="library_db.txt" 
BORROWERS_DB="borrowers_db.txt" 
STUDENTS_DB="students_db.txt" 
USERS_DB="users_db.txt" 
# Ensuring the database files exist 
touch $LIBRARY_DB $BORROWERS_DB $STUDENTS_DB $USERS_DB 
# Global variables 
LOGGED_IN_USER="" 
BASE_WINDOW_TITLE="Library Management System" 
# Function to handle user login 
login() { 
while true; do 
username=$(zenity --entry --title="Login" --text="Enter Username:" --width=300) 
password=$(zenity --entry --title="Login" --text="Enter Password:" --hide-text --width=300) 
if grep -q "^$username:$password$" $USERS_DB; then 
LOGGED_IN_USER=$username 
zenity --info --title="Login Successful" --text="Welcome, $username!" --width=300 
return 0 
else 
zenity --error --title="Login Failed" --text="Invalid credentials!" --width=300 
return 1 
fi 
done 
} 
# Function to handle user registration 
register() { 
while true; do 
username=$(zenity --entry --title="Sign Up" --text="Enter a username:" --width=300) 
if grep -q "^$username:" $USERS_DB; then 
zenity --warning --title="Registration Failed" --text="Username already exists!" --width=300 
else 
password=$(zenity --entry --title="Sign Up" --text="Enter a password:" --hide-text --width=300) 
echo "$username:$password" >> $USERS_DB 
zenity --info --title="Registration Successful" --text="User registered successfully!" --width=300 
return 0 
fi 
done 
} 
# Function to list all books 
list_books() { 
if [ -s "$LIBRARY_DB" ]; then 
zenity --text-info --title="List of Books" --filename="$LIBRARY_DB" --width=600 --height=400 
else 
zenity --info --title="Library" --text="No books available." --width=300 
fi 
} 
# Function to add a book 
add_book() { 
book_title=$(zenity --entry --title="Add a Book" --text="Enter book title:" --width=300) 
book_author=$(zenity --entry --title="Add a Book" --text="Enter author name:" --width=300) 
if [ -n "$book_title" ] && [ -n "$book_author" ]; then 
echo "Title: $book_title | Author: $book_author" >> $LIBRARY_DB 
zenity --info --title="Book Added" --text="Book added successfully!" --width=300 
else 
zenity --warning --title="Error" --text="Book title and author cannot be empty!" --width=300 
fi 
} 
# Function to borrow a book 
borrow_book() { 
student_id=$(zenity --entry --title="Borrow a Book" --text="Enter your library ID (e.g., S123):" -- 
width=300) 
if grep -q "ID: $student_id" $STUDENTS_DB; then 
book_to_borrow=$(zenity --entry --title="Borrow a Book" --text="Enter book title to borrow:" -- 
width=300) 
if grep -q "Title: $book_to_borrow" $LIBRARY_DB; then 
borrowed_date=$(date '+%Y-%m-%d') 
return_date=$(date -d "$borrowed_date + 15 days" '+%Y-%m-%d') 
echo "Student ID: $student_id | Book: $book_to_borrow | Borrowed Date: $borrowed_date | 
Return Date: $return_date" >> $BORROWERS_DB 
zenity --info --title="Book Borrowed" --text="Return by $return_date" --width=300 
else 
fi 
zenity --warning --title="Error" --text="Book not available!" --width=300 
else 
zenity --warning --title="Error" --text="Invalid Library ID!" --width=300 
fi 
} 
# Function to return a book 
return_book() { 
student_id=$(zenity --entry --title="Return a Book" --text="Enter your library ID (e.g., S123):" -- 
width=300) 
book_to_return=$(zenity --entry --title="Return a Book" --text="Enter book title to return:" -- 
width=300) 
if grep -q "$student_id | Book: $book_to_return" $BORROWERS_DB; then 
grep -v "$student_id | Book: $book_to_return" $BORROWERS_DB > temp_db && mv temp_db 
$BORROWERS_DB 
zenity --info --title="Book Returned" --text="Book returned successfully!" --width=300 
else 
zenity --warning --title="Error" --text="Book not found or incorrect details!" --width=300 
fi 
} 
# Function to create a library ID 
create_library_id() { 
student_name=$(zenity --entry --title="Create Library ID" --text="Enter student's name:" --width=300) 
if [ -n "$student_name" ]; then 
student_id=$(awk 'END {print NR+1}' $STUDENTS_DB) 
echo "ID: S$student_id | Name: $student_name" >> $STUDENTS_DB 
zenity --info --title="Library ID Created" --text="Library ID created: S$student_id" --width=300 
else 
zenity --warning --title="Error" --text="Student name cannot be empty!" --width=300 
fi 
} 
# Function to remove a library ID 
remove_library_id() { 
student_id_to_remove=$(zenity --entry --title="Remove Library ID" --text="Enter the library ID to 
remove (e.g., S123):" --width=300) 
if [ -n "$student_id_to_remove" ]; then 
grep -v "$student_id_to_remove" $STUDENTS_DB > temp_db && mv temp_db $STUDENTS_DB 
zenity --info --title="Library ID Removed" --text="Library ID $student_id_to_remove removed 
successfully!" --width=300 
else 
zenity --warning --title="Error" --text="Library ID cannot be empty!" --width=300 
fi 
} 
# Function to remove a book 
remove_book() { 
book_title=$(zenity --entry --title="Remove a Book" --text="Enter book title to remove:" --width=300) 
if [ -n "$book_title" ]; then 
grep -v "Title: $book_title" $LIBRARY_DB > temp_db && mv temp_db $LIBRARY_DB 
zenity --info --title="Book Removed" --text="Book removed successfully!" --width=300 
else 
zenity --warning --title="Error" --text="Book title cannot be empty!" --width=300 
fi 
} 
# Function to view all book borrowers 
view_borrowers() { 
if [ -s "$BORROWERS_DB" ]; then 
zenity --text-info --title="List of Borrowers" --filename="$BORROWERS_DB" --width=600 -- 
height=400 
else 
zenity --info --title="Borrowers" --text="No borrowers found." --width=300 
fi 
} 
# Main entry point: Login, Sign Up, or Exit 
initial_screen() { 
while true; do 
choice=$(zenity --list --title="$BASE_WINDOW_TITLE" --column="Choose an option" "Login" 
"Sign Up" "Exit" --width=300 --height=200) 
case $choice in 
"Login") 
if login; then return 0; fi ;; 
"Sign Up") 
if register; then return 0; fi ;; 
"Exit") 
exit 0 ;; # Exit the script 
*) 
exit 0 ;; # Handle cancel or other invalid selections 
esac 
done 
} 
# Main Menu 
show_main_menu() { 
while true; do 
choice=$(zenity --list --title="$BASE_WINDOW_TITLE" --column="Options" "1) List Books" "2) 
Add Book" "3) Borrow Book" "4) Return Book" "5) Remove Book" "6) View Borrowers" "7) Create 
Library ID" "8) Remove Library ID" "9) Logout" --width=400 --height=300) 
case $choice in 
"1) List Books") list_books ;; 
"2) Add Book") add_book ;; 
"3) Borrow Book") borrow_book ;; 
"4) Return Book") return_book ;; 
"5) Remove Book") remove_book ;; 
"6) View Borrowers") view_borrowers ;; 
"7) Create Library ID") create_library_id ;; 
"8) Remove Library ID") remove_library_id ;; 
"9) Logout") 
LOGGED_IN_USER="" 
zenity --info --title="Logged Out" --text="You have been logged out." --width=300 
return 0 ;; 
*) 
esac 
done 
} 
exit 0 ;; # Handle cancel or other invalid selections 
# Main Program 
initial_screen 
if [ -n "$LOGGED_IN_USER" ]; then 
show_main_menu 
fi
