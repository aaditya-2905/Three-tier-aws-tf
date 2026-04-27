const express = require('express');
const { createPool } = require('mysql2/promise');
const cors = require('cors');
const dotenv = require('dotenv');

dotenv.config();

const app = express();
app.use(express.json());
app.use(cors());

const db = createPool({
    host: process.env.DB_HOST,
    user: process.env.DB_USER,
    password: process.env.DB_PASSWORD,
    database: process.env.DB_NAME,
    connectionLimit: 10,
});

console.log("DB CONFIG:", {
    host: process.env.DB_HOST,
    user: process.env.DB_USER,
    database: process.env.DB_NAME
});

process.on('unhandledRejection', (err) => {
    console.error('Unhandled Rejection:', err);
});

process.on('uncaughtException', (err) => {
    console.error('Uncaught Exception:', err);
});

app.get('/api/health', async (req, res) => {
    try {
        await db.query("SELECT 1");
        res.status(200).json({ status: "healthy" });
    } catch (err) {
        console.error("Health check failed:", err);
        res.status(500).json({ status: "unhealthy" });
    }
});


const router = express.Router();

/* ===== GET STUDENTS ===== */
router.get('/student', async (req, res) => {
    try {
        const [data] = await db.query("SELECT * FROM student");
        res.json(data);
    } catch (err) {
        console.error("GET student error:", err);
        res.status(500).json({ error: err.message });
    }
});

/* ===== GET TEACHERS ===== */
router.get('/teacher', async (req, res) => {
    try {
        const [data] = await db.query("SELECT * FROM teacher");
        res.json(data);
    } catch (err) {
        console.error("GET teacher error:", err);
        res.status(500).json({ error: err.message });
    }
});

/* ===== ADD STUDENT ===== */
router.post('/addstudent', async (req, res) => {
    try {
        const { name, rollNo, class: cls } = req.body;

        if (!name || !rollNo) {
            return res.status(400).json({ error: "Missing required fields" });
        }

        const [result] = await db.query(
            "INSERT INTO student (name, roll_number, class) VALUES (?, ?, ?)",
            [name, rollNo, cls]
        );

        res.json({ message: "Student added", id: result.insertId });
    } catch (err) {
        console.error("POST student error:", err);
        res.status(500).json({ error: err.message });
    }
});

/* ===== ADD TEACHER ===== */
router.post('/addteacher', async (req, res) => {
    try {
        const { name, subject, class: cls } = req.body;

        if (!name || !subject) {
            return res.status(400).json({ error: "Missing required fields" });
        }

        const [result] = await db.query(
            "INSERT INTO teacher (name, subject, class) VALUES (?, ?, ?)",
            [name, subject, cls]
        );

        res.json({ message: "Teacher added", id: result.insertId });
    } catch (err) {
        console.error("POST teacher error:", err);
        res.status(500).json({ error: err.message });
    }
});

/* ===== DELETE STUDENT ===== */
router.delete('/student/:id', async (req, res) => {
    try {
        const { id } = req.params;

        await db.query("DELETE FROM student WHERE id = ?", [id]);

        res.json({ message: "Student deleted" });
    } catch (err) {
        console.error("DELETE student error:", err);
        res.status(500).json({ error: err.message });
    }
});

/* ===== DELETE TEACHER ===== */
router.delete('/teacher/:id', async (req, res) => {
    try {
        const { id } = req.params;

        await db.query("DELETE FROM teacher WHERE id = ?", [id]);

        res.json({ message: "Teacher deleted" });
    } catch (err) {
        console.error("DELETE teacher error:", err);
        res.status(500).json({ error: err.message });
    }
});

app.use('/api', router);

const PORT = 3000;
app.listen(PORT, () => {
    console.log(`Server running on port ${PORT}`);
});