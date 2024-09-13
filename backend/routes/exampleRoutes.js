// backend/routes/exampleRoutes.js
const express = require('express');
const { getExample } = require('../controllers/exampleController');
const router = express.Router();

/**
 * @swagger
 * /api/example:
 *   get:
 *     summary: Returns example data
 *     responses:
 *       200:
 *         description: Success
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 message:
 *                   type: string
 */
router.get('/example', getExample);

module.exports = router;
