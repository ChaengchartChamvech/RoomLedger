import { Router } from 'express';
import pool from '../db.js';

const router = Router();

router.get('/', async (_req, res) => {
  try {
    const [rows] = await pool.query(
      `SELECT id, title, location, monthly_price, is_available
       FROM rooms
       ORDER BY created_at DESC`
    );
    res.json(rows);
  } catch (error) {
    console.error('GET /rooms error:', error);
    res.status(500).json({ message: 'Internal server error' });
  }
});

router.post('/', async (req, res) => {
  const { title, location, monthly_price: monthlyPrice } = req.body;
  if (!title || !location || !monthlyPrice) {
    return res.status(400).json({
      message: 'title, location and monthly_price are required'
    });
  }

  try {
    const [result] = await pool.execute(
      `INSERT INTO rooms (title, location, monthly_price, is_available)
       VALUES (?, ?, ?, 1)`,
      [title, location, Number(monthlyPrice)]
    );

    return res.status(201).json({
      id: result.insertId,
      title,
      location,
      monthly_price: Number(monthlyPrice),
      is_available: 1
    });
  } catch (error) {
    console.error('POST /rooms error:', error);
    return res.status(500).json({ message: 'Internal server error' });
  }
});

export default router;
