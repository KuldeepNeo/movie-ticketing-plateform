const express = require('express');
const cityController = require('../controllers/cityController');

const router = express.Router();

// Public endpoint to list active cities
router.get('/', cityController.getCities);

module.exports = router;
