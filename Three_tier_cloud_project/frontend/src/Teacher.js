import React, { useState, useEffect, useCallback } from 'react';
import './Teacher.css';

function Teacher() {
  const [TeacherData, setTeacherData] = useState({
    name: '',
    subject: '',
    class: ''
  });

  const [data, setData] = useState([]);

  const API_BASE_URL = "/api";

  // ✅ Safe response handler
  const handleResponse = async (res) => {
    if (!res.ok) {
      const text = await res.text();
      throw new Error(text);
    }
    return res.json();
  };

  const getData = useCallback(() => {
    fetch(`${API_BASE_URL}/teacher`)
      .then(handleResponse)
      .then((data) => setData(data))
      .catch((err) => console.log("GET Error:", err.message));
  }, [API_BASE_URL]);

  useEffect(() => {
    getData();
  }, [getData]);

  const handleInputChange = (e) => {
    const { name, value } = e.target;
    setTeacherData({ ...TeacherData, [name]: value });
  };

  const handleSubmit = (e) => {
    e.preventDefault();

    const requestOptions = {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(TeacherData)
    };

    fetch(`${API_BASE_URL}/addteacher`, requestOptions)
      .then(handleResponse)
      .then(() => {
        getData();
      })
      .catch((err) => console.log("POST Error:", err.message));

    setTeacherData({
      name: '',
      subject: '',
      class: ''
    });
  };

  const handleDelete = (id) => {
    fetch(`${API_BASE_URL}/teacher/${id}`, {
      method: 'DELETE',
    })
      .then(handleResponse)
      .then(() => {
        getData();
      })
      .catch((err) => console.log("DELETE Error:", err.message));
  };

  return (
    <div>
      <h2>Teacher Details</h2>

      <form onSubmit={handleSubmit}>
        <input
          name="name"
          value={TeacherData.name}
          onChange={handleInputChange}
          placeholder="Name"
          required
        />
        <input
          name="subject"
          value={TeacherData.subject}
          onChange={handleInputChange}
          placeholder="Subject"
          required
        />
        <input
          name="class"
          value={TeacherData.class}
          onChange={handleInputChange}
          placeholder="Class"
        />

        <button type="submit">Submit</button>
      </form>

      <table>
        <thead>
          <tr>
            <th>ID</th>
            <th>Name</th>
            <th>Subject</th>
            <th>Class</th>
            <th>Action</th>
          </tr>
        </thead>

        <tbody>
          {data.map((d) => (
            <tr key={d.id}>
              <td>{d.id}</td>
              <td>{d.name}</td>
              <td>{d.subject}</td>
              <td>{d.class}</td>
              <td>
                <button onClick={() => handleDelete(d.id)}>Delete</button>
              </td>
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
}

export default Teacher;