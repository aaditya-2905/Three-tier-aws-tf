import React, { useState, useEffect } from 'react';
import './Student.css';

function Student() {
  const [studentData, setStudentData] = useState({
    name: '',
    rollNo: '',
    class: '',
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

  const getData = () => {
    fetch(`${API_BASE_URL}/student`)
      .then(handleResponse)
      .then((data) => {
        console.log('Fetched Data:', data);
        setData(data);
      })
      .catch((err) => console.log("GET Error:", err.message));
  };

  useEffect(() => {
    getData();
  }, []);

  const handleInputChange = (e) => {
    const { name, value } = e.target;
    setStudentData({ ...studentData, [name]: value });
  };

  const handleSubmit = (e) => {
    e.preventDefault();

    const requestOptions = {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(studentData),
    };

    fetch(`${API_BASE_URL}/addstudent`, requestOptions)
      .then(handleResponse)
      .then(() => {
        getData();
      })
      .catch((err) => console.log("POST Error:", err.message));

    setStudentData({
      name: '',
      rollNo: '',
      class: '',
    });
  };

  const handleDelete = (id) => {
    fetch(`${API_BASE_URL}/student/${id}`, {
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
      <div className="student-container">
        <div className="content">
          <h2 style={{ marginLeft: '100px' }}>Student Details</h2>

          <form onSubmit={handleSubmit}>
            <input name="name" value={studentData.name} onChange={handleInputChange} placeholder="Name" />
            <input name="rollNo" value={studentData.rollNo} onChange={handleInputChange} placeholder="Roll No" />
            <input name="class" value={studentData.class} onChange={handleInputChange} placeholder="Class" />

            <button type="submit">Submit</button>
          </form>
        </div>

        <table>
          <thead>
            <tr>
              <th>ID</th>
              <th>Name</th>
              <th>Roll</th>
              <th>Class</th>
              <th>Action</th>
            </tr>
          </thead>

          <tbody>
            {data.map((d) => (
              <tr key={d.id}>
                <td>{d.id}</td>
                <td>{d.name}</td>
                <td>{d.roll_number}</td>
                <td>{d.class}</td>
                <td>
                  <button onClick={() => handleDelete(d.id)}>Delete</button>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </div>
  );
}

export default Student;