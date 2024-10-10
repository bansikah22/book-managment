// src/App.js
import React from 'react';
import { BrowserRouter as Router, Route, Routes } from 'react-router-dom';
import BookManager from './components/BookManager'; 
import Login from './components/Login'; // Import the Login component

function App() {
  return (
    <Router>
      <div>
        <Routes>
          <Route path="/login" element={<Login />} /> {/* Add the route for Login */}
          <Route path="/home" element={<BookManager />} /> {/* The route for your BookManager */}
          <Route path="/" element={<Login />} /> {/* Redirect root to login */}
        </Routes>
      </div>
    </Router>
  );
}

export default App;
