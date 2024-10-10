// src/components/ProtectedRoute.js
import React, { useEffect, useState } from 'react';
import { Navigate } from 'react-router-dom';

const ProtectedRoute = ({ children }) => {
  const [isAuthenticated, setIsAuthenticated] = useState(null);

  useEffect(() => {
    const backendUrl = process.env.REACT_APP_BACKEND_URL; // Use the env variable for backend URL
    fetch(`${backendUrl}/api/user`, { credentials: 'include' })
      .then(response => {
        if (response.ok) {
          setIsAuthenticated(true);
        } else {
          setIsAuthenticated(false);
        }
      })
      .catch(() => setIsAuthenticated(false));
  }, []);

  if (isAuthenticated === null) {
    return <p>Loading...</p>; // Show a loading indicator while checking authentication
  }

  if (!isAuthenticated) {
    return <Navigate to="/" />; // Redirect to login if not authenticated
  }

  return children;
};

export default ProtectedRoute;
