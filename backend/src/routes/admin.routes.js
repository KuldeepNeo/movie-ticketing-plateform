const express = require('express');
const adminMovieController = require('../controllers/adminMovieController');
const adminTheaterController = require('../controllers/adminTheaterController');
const adminScreenController = require('../controllers/adminScreenController');
const authMiddleware = require('../middlewares/authMiddleware');
const roleMiddleware = require('../middlewares/roleMiddleware');
const validationMiddleware = require('../middlewares/validationMiddleware');

const {
  movieCreateSchema,
  movieUpdateSchema,
  theaterCreateSchema,
  theaterUpdateSchema,
  screenCreateSchema,
  screenUpdateSchema
} = require('../validators/adminSchemas');

const router = express.Router();

// Apply strict RBAC authentication checks for all admin endpoints
router.use(authMiddleware);
router.use(roleMiddleware('admin'));

// --- Movie Management ---
router.get('/movies', adminMovieController.getMovies);
router.post('/movies', validationMiddleware(movieCreateSchema), adminMovieController.createMovie);
router.put('/movies/:id', validationMiddleware(movieUpdateSchema), adminMovieController.updateMovie);
router.delete('/movies/:id', adminMovieController.deleteMovie);

// --- Theater Management ---
router.get('/theaters', adminTheaterController.getTheaters);
router.post('/theaters', validationMiddleware(theaterCreateSchema), adminTheaterController.createTheater);
router.put('/theaters/:id', validationMiddleware(theaterUpdateSchema), adminTheaterController.updateTheater);
router.delete('/theaters/:id', adminTheaterController.deleteTheater);

// --- Screen Management ---
router.get('/theaters/:theaterId/screens', adminScreenController.getScreens);
router.post('/theaters/:theaterId/screens', validationMiddleware(screenCreateSchema), adminScreenController.createScreen);
router.put('/screens/:id', validationMiddleware(screenUpdateSchema), adminScreenController.updateScreen);
router.delete('/screens/:id', adminScreenController.deleteScreen);

module.exports = router;
