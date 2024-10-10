// src/components/Login.js
import React, { useState } from 'react';

const Login = () => {
    const [username, setUsername] = useState('');
    const [email, setEmail] = useState('');

    const handleLogin = () => {
        // Redirect to Spring Boot OAuth2 GitHub login endpoint
        window.location.href = `${process.env.REACT_APP_BACKEND_URL}/oauth2/authorization/github`;
    };

    const handleSubmit = (e) => {
        e.preventDefault();
        // You can handle form submission here if needed, e.g., send data to your backend
        console.log('Username:', username, 'Email:', email);
    };

    return (
        <div style={{ display: 'flex', justifyContent: 'center', alignItems: 'center', height: '100vh' }}>
            <div style={{ border: '1px solid #ccc', padding: '20px', borderRadius: '5px', width: '300px', boxShadow: '0 2px 10px rgba(0,0,0,0.1)' }}>
                <h1 style={{ textAlign: 'center' }}>Login</h1>
                <form onSubmit={handleSubmit} style={{ display: 'flex', flexDirection: 'column' }}>
                    <input
                        type="text"
                        placeholder="Username"
                        value={username}
                        onChange={(e) => setUsername(e.target.value)}
                        style={{ marginBottom: '10px', padding: '10px', border: '1px solid #ccc', borderRadius: '5px' }}
                        required
                    />
                    <input
                        type="email"
                        placeholder="Email"
                        value={email}
                        onChange={(e) => setEmail(e.target.value)}
                        style={{ marginBottom: '10px', padding: '10px', border: '1px solid #ccc', borderRadius: '5px' }}
                        required
                    />
                    <button type="submit" style={{ marginBottom: '10px', padding: '10px', backgroundColor: '#007bff', color: '#fff', border: 'none', borderRadius: '5px', cursor: 'pointer' }}>
                        Submit
                    </button>
                </form>
                <div style={{ textAlign: 'center', margin: '10px 0' }}>or</div>
                <button onClick={handleLogin} style={{ width: '100%', padding: '10px', backgroundColor: '#28a745', color: '#fff', border: 'none', borderRadius: '5px', cursor: 'pointer' }}>
                    Login with GitHub
                </button>
            </div>
        </div>
    );
};

export default Login;
