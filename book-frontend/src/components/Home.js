// src/components/Home.js
import React, { useEffect, useState } from 'react';
import BookManager from './BookManager';

const Home = () => {
  const [user, setUser] = useState(null);

  useEffect(() => {
    const backendUrl = process.env.REACT_APP_BACKEND_URL;
    // Fetch user details from backend API after login
    fetch(`${backendUrl}/api/user`, { credentials: 'include' })
      .then(response => response.json())
      .then(data => setUser(data))
      .catch(error => console.error('Error fetching user data:', error));
  }, []);

  return (
    <div>
      <h1>Welcome to the Book Application</h1>
      {user ? (
        <div>
          <h2>Hello, {user.name}!</h2>
          <p>Email: {user.email}</p>
          <BookManager />
        </div>
      ) : (
        <p>Loading user details...</p>
      )}
    </div>
  );
};

export default Home;
