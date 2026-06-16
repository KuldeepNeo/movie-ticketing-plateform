const express = require('express');
const authRoutes = require('./auth.routes');
const cityRoutes = require('./city.routes');
const adminRoutes = require('./admin.routes');

const router = express.Router();

// Mount auth module routes under /auth
router.use('/auth', authRoutes);

// Mount cities module routes under /cities
router.use('/cities', cityRoutes);

// Mount admin module routes under /admin
router.use('/admin', adminRoutes);

module.exports = router;
