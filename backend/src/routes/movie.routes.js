const express = require('express');
const movieController = require('../controllers/movieController');

const router = express.Router();

// Public movie discovery routes
router.get('/', movieController.getMovies);
router.get('/:id', movieController.getMovieById);

module.exports = router;
