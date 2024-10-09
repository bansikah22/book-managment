// src/components/BookManager.js
import React, { useEffect, useState } from "react";
import axios from "axios";
import './BookManager.css'; // Import CSS for styling

const backendUrl = process.env.REACT_APP_BACKEND_URL; // Set this in your .env file

const BookManager = () => {
    const [books, setBooks] = useState([]);
    const [title, setTitle] = useState("");
    const [author, setAuthor] = useState("");
    const [file, setFile] = useState(null);
    const [editMode, setEditMode] = useState(false); // Track if we're editing
    const [currentBookId, setCurrentBookId] = useState(null); // Store current book ID for editing

    useEffect(() => {
        const fetchBooks = async () => {
            try {
                const response = await axios.get(`${backendUrl}/api/books`);
                setBooks(response.data);
            } catch (error) {
                console.error("Error fetching books:", error);
            }
        };
        fetchBooks();
    }, []);

    const handleSubmit = async (event) => {
        event.preventDefault();
        const formData = new FormData();
        formData.append("title", title);
        formData.append("author", author);
        if (file) {
            formData.append("file", file);
        }

        try {
            if (editMode) {
                // Update book
                await axios.put(`${backendUrl}/api/books/${currentBookId}`, formData, {
                    headers: {
                        "Content-Type": "multipart/form-data",
                    },
                });
                setEditMode(false);
                setCurrentBookId(null); // Reset current book ID
            } else {
                // Create new book
                await axios.post(`${backendUrl}/api/books`, formData, {
                    headers: {
                        "Content-Type": "multipart/form-data",
                    },
                });
            }

            // Fetch books again after adding or updating
            const response = await axios.get(`${backendUrl}/api/books`);
            setBooks(response.data);
            // Reset form fields
            setTitle("");
            setAuthor("");
            setFile(null);
        } catch (error) {
            console.error("Error saving book:", error);
        }
    };

    // Function to handle file download
    const handleDownload = async (id) => {
        try {
            const response = await axios.get(`${backendUrl}/api/books/download/${id}`, {
                responseType: 'blob',
            });

            const url = window.URL.createObjectURL(new Blob([response.data]));
            const link = document.createElement('a');
            link.href = url;
            link.setAttribute('download', `book_${id}.pdf`);
            document.body.appendChild(link);
            link.click();
            link.remove();
        } catch (error) {
            console.error("Error downloading the file:", error);
        }
    };

    // Function to handle deleting a book
    const handleDelete = async (id) => {
        try {
            await axios.delete(`${backendUrl}/api/books/${id}`);
            // Fetch books again after deletion
            const response = await axios.get(`${backendUrl}/api/books`);
            setBooks(response.data);
        } catch (error) {
            console.error("Error deleting the book:", error);
        }
    };

    // Function to handle editing a book
    const handleEdit = (book) => {
        setTitle(book.title);
        setAuthor(book.author);
        setCurrentBookId(book.id);
        setEditMode(true);
    };

    return (
        <div className="container">
            <h2>Book Manager</h2>
            <form onSubmit={handleSubmit} className="book-form">
                <input
                    type="text"
                    placeholder="Title"
                    value={title}
                    onChange={(e) => setTitle(e.target.value)}
                    required
                    className="form-input"
                />
                <input
                    type="text"
                    placeholder="Author"
                    value={author}
                    onChange={(e) => setAuthor(e.target.value)}
                    required
                    className="form-input"
                />
                <input
                    type="file"
                    onChange={(e) => setFile(e.target.files[0])}
                    className="form-input"
                />
                <button type="submit" className="submit-button">{editMode ? "Update Book" : "Add Book"}</button>
            </form>
            <h3>Book List</h3>
            <table className="book-table">
                <thead>
                    <tr>
                        <th>ID</th>
                        <th>Title</th>
                        <th>Author</th>
                        <th>File Path</th>
                        <th>Actions</th>
                    </tr>
                </thead>
                <tbody>
                    {books.map((book) => (
                        <tr key={book.id}>
                            <td>{book.id}</td>
                            <td>{book.title}</td>
                            <td>{book.author}</td>
                            <td>{book.filePath}</td>
                            <td>
                                <button onClick={() => handleDownload(book.id)} className="download-button">
                                    Download
                                </button>
                                <button onClick={() => handleEdit(book)} className="edit-button">
                                    Edit
                                </button>
                                <button onClick={() => handleDelete(book.id)} className="delete-button">
                                    Delete
                                </button>
                            </td>
                        </tr>
                    ))}
                </tbody>
            </table>
        </div>
    );
};

export default BookManager;
