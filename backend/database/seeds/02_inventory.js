/**
 * @param { import("knex").Knex } knex
 * @returns { Promise<void> } 
 */
exports.seed = async function(knex) {
  // Deletes ALL existing entries in reverse dependency order
  await knex('seats').del();
  await knex('screens').del();
  await knex('theaters').del();
  await knex('movies').del();
  await knex('cities').del();

  const now = new Date().toISOString();

  // 1. Insert Cities
  await knex('cities').insert([
    { id: 1, name: 'Mumbai', status: 'active', created_at: now, updated_at: now },
    { id: 2, name: 'Delhi', status: 'active', created_at: now, updated_at: now },
    { id: 3, name: 'Bengaluru', status: 'active', created_at: now, updated_at: now }
  ]);

  // 2. Insert Movies
  await knex('movies').insert([
    {
      id: 1,
      title: 'Galactic Storm',
      synopsis: 'A team of astronauts must save Earth from an interstellar threat...',
      runtime_minutes: 148,
      language: 'English',
      genre: 'Action',
      age_rating: 'U/A',
      poster_url: 'https://cdn.example.com/posters/galactic-storm.jpg',
      banner_url: 'https://cdn.example.com/banners/galactic-storm.jpg',
      status: 'published',
      created_at: now,
      updated_at: now
    },
    {
      id: 2,
      title: 'Inception',
      synopsis: 'A thief who steals corporate secrets through the use of dream-sharing technology...',
      runtime_minutes: 148,
      language: 'English',
      genre: 'Sci-Fi',
      age_rating: 'U/A',
      poster_url: 'https://cdn.example.com/posters/inception.jpg',
      banner_url: 'https://cdn.example.com/banners/inception.jpg',
      status: 'published',
      created_at: now,
      updated_at: now
    }
  ]);

  // 3. Insert Theaters
  await knex('theaters').insert([
    {
      id: 1,
      name: 'PVR Multiplex',
      address: '100 Feet Road, Indiranagar, Bengaluru',
      city_id: 3, // Bengaluru
      area: 'Indiranagar',
      status: 'active',
      created_at: now,
      updated_at: now
    },
    {
      id: 2,
      name: 'INOX Forum',
      address: 'Koramangala Mall, Bengaluru',
      city_id: 3, // Bengaluru
      area: 'Koramangala',
      status: 'active',
      created_at: now,
      updated_at: now
    }
  ]);

  // 4. Insert Screens
  await knex('screens').insert([
    {
      id: 1,
      theater_id: 1,
      name: 'Screen 1',
      rows_count: 5,
      columns_count: 6,
      status: 'active',
      created_at: now,
      updated_at: now
    },
    {
      id: 2,
      theater_id: 2,
      name: 'IMAX 3D',
      rows_count: 4,
      columns_count: 5,
      status: 'active',
      created_at: now,
      updated_at: now
    }
  ]);

  // 5. Generate seats for Screen 1 (5 rows: A-E, 6 columns: 1-6)
  const seatsScreen1 = [];
  for (let r = 0; r < 5; r++) {
    const rowLabel = String.fromCharCode(65 + r); // A, B, C, D, E
    const category = r < 2 ? 'premium' : 'classic'; // Row A-B premium, others classic
    for (let c = 1; c <= 6; c++) {
      seatsScreen1.push({
        screen_id: 1,
        row_label: rowLabel,
        column_number: c,
        seat_category: category,
        status: 'active',
        created_at: now,
        updated_at: now
      });
    }
  }
  await knex('seats').insert(seatsScreen1);

  // 6. Generate seats for Screen 2 (4 rows: A-D, 5 columns: 1-5)
  const seatsScreen2 = [];
  for (let r = 0; r < 4; r++) {
    const rowLabel = String.fromCharCode(65 + r); // A, B, C, D
    const category = r === 0 ? 'recliner' : (r === 1 ? 'premium' : 'classic');
    for (let c = 1; c <= 5; c++) {
      seatsScreen2.push({
        screen_id: 2,
        row_label: rowLabel,
        column_number: c,
        seat_category: category,
        status: 'active',
        created_at: now,
        updated_at: now
      });
    }
  }
  await knex('seats').insert(seatsScreen2);
};
