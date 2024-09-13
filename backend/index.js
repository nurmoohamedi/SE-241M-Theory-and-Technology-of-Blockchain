// backend/index.js
const express = require('express');
const dotenv = require('dotenv');
const swaggerUi = require('swagger-ui-express');
const swaggerJsdoc = require('swagger-jsdoc');
const exampleRoutes = require('./routes/exampleRoutes');  // Import your routes

dotenv.config();  // Load environment variables from .env file

const app = express();
app.use(express.json());  // Middleware to parse JSON

// API Routes
app.use('/api', exampleRoutes);

// Swagger setup
const swaggerOptions = {
  swaggerDefinition: {
    openapi: '3.0.0',
    info: {
      title: 'Blockchain API',
      version: '1.0.0',
      description: 'API documentation for Blockchain Project',
    },
    servers: [
      {
        url: 'http://localhost:3000',
      },
    ],
  },
  apis: ['./routes/*.js'],  // Location of your route files for automatic documentation
};

const swaggerDocs = swaggerJsdoc(swaggerOptions);
app.use('/api-docs', swaggerUi.serve, swaggerUi.setup(swaggerDocs));

// Start the backend server
const PORT = process.env.PORT || 3000;
app.listen(PORT, () => console.log(`Server running on port ${PORT}`));
