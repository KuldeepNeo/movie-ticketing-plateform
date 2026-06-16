const baseUrl = 'http://localhost:3000/api/v1';

// Simple helper to log test assertions
function assert(condition, message) {
  if (condition) {
    console.log(`✅ [PASS] ${message}`);
  } else {
    console.error(`❌ [FAIL] ${message}`);
    process.exitCode = 1;
  }
}

async function run() {
  console.log('🏁 Starting API Integration Testing for Auth Module...\n');

  const testEmail = `qa.test.${Date.now()}@example.com`;
  let accessToken = '';
  let refreshToken = '';

  // --- KPI-AUTH-001: Register user ---
  try {
    const res = await fetch(`${baseUrl}/auth/register`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        name: 'QA Tester',
        email: testEmail,
        password: 'SecureP@ss1',
        confirm_password: 'SecureP@ss1'
      })
    });
    
    assert(res.status === 201, `POST /auth/register status is 201 (Actual: ${res.status})`);
    
    const body = await res.json();
    assert(body.status === 'success', 'Registration response status is "success"');
    assert(body.data.email === testEmail, 'User email matches registration input');
    assert(body.data.role === 'customer', 'User role defaults to "customer"');
    assert(body.data.id !== undefined, 'User ID is returned in payload');
  } catch (err) {
    console.error('❌ Registration failed due to request error:', err);
    process.exitCode = 1;
  }

  // --- KPI-AUTH-002: Duplicate email registration prevention ---
  try {
    const res = await fetch(`${baseUrl}/auth/register`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        name: 'QA Tester 2',
        email: testEmail,
        password: 'SecureP@ss1',
        confirm_password: 'SecureP@ss1'
      })
    });
    
    assert(res.status === 409, `Duplicate registration returns 409 Conflict (Actual: ${res.status})`);
    
    const body = await res.json();
    assert(body.status === 'error', 'Response status is "error"');
    assert(body.code === 'CONFLICT', 'Error code matches "CONFLICT"');
    assert(body.message === 'Email address already registered.', 'Error message indicates duplicate email');
  } catch (err) {
    console.error('❌ Duplicate validation failed due to request error:', err);
    process.exitCode = 1;
  }

  // --- KPI-AUTH-004: Invalid login credentials rejected ---
  try {
    const res = await fetch(`${baseUrl}/auth/login`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        email: testEmail,
        password: 'WrongPassword123'
      })
    });
    
    assert(res.status === 401, `Invalid login password returns 401 Unauthorized (Actual: ${res.status})`);
    
    const body = await res.json();
    assert(body.status === 'error', 'Invalid login response status is "error"');
    assert(body.code === 'UNAUTHORIZED', 'Invalid login error code is "UNAUTHORIZED"');
  } catch (err) {
    console.error('❌ Invalid login testing failed due to request error:', err);
    process.exitCode = 1;
  }

  // --- KPI-AUTH-003: User can log in successfully ---
  try {
    const res = await fetch(`${baseUrl}/auth/login`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        email: testEmail,
        password: 'SecureP@ss1'
      })
    });
    
    assert(res.status === 200, `POST /auth/login status is 200 (Actual: ${res.status})`);
    
    const body = await res.json();
    assert(body.status === 'success', 'Login response status is "success"');
    assert(body.data.access_token !== undefined, 'Access token is returned');
    assert(body.data.refresh_token !== undefined, 'Refresh token is returned');
    assert(body.data.user.email === testEmail, 'Logged-in user email matches');
    
    accessToken = body.data.access_token;
    refreshToken = body.data.refresh_token;
  } catch (err) {
    console.error('❌ Login validation failed due to request error:', err);
    process.exitCode = 1;
  }

  // --- KPI-AUTH-006: Session management functions correctly (access profile) ---
  try {
    // 1. Authorized request with token
    const res = await fetch(`${baseUrl}/auth/me`, {
      method: 'GET',
      headers: {
        'Accept': 'application/json',
        'Authorization': `Bearer ${accessToken}`
      }
    });
    
    assert(res.status === 200, `GET /auth/me returns 200 OK with valid token (Actual: ${res.status})`);
    const body = await res.json();
    assert(body.data.email === testEmail, 'Me profile email matches session');

    // 2. Unauthorized request without token
    const resNoToken = await fetch(`${baseUrl}/auth/me`, {
      method: 'GET',
      headers: { 'Accept': 'application/json' }
    });
    assert(resNoToken.status === 401, `GET /auth/me without token returns 401 Unauthorized (Actual: ${resNoToken.status})`);

    // 3. Unauthorized request with bad token
    const resBadToken = await fetch(`${baseUrl}/auth/me`, {
      method: 'GET',
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer bad_token_signature_value'
      }
    });
    assert(resBadToken.status === 401, `GET /auth/me with bad token returns 401 Unauthorized (Actual: ${resBadToken.status})`);
  } catch (err) {
    console.error('❌ Session management validation failed due to request error:', err);
    process.exitCode = 1;
  }

  // --- JWT Expiry and Refresh Token mechanism ---
  try {
    const res = await fetch(`${baseUrl}/auth/refresh`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        refresh_token: refreshToken
      })
    });
    
    assert(res.status === 200, `POST /auth/refresh returns 200 OK (Actual: ${res.status})`);
    
    const body = await res.json();
    assert(body.status === 'success', 'Token refresh response status is "success"');
    assert(body.data.access_token !== undefined, 'New access token is generated');
    assert(body.data.expires_in === 900, 'Expiration is set correctly to 900s');

    // Verify the new token works on protected route
    const testNewToken = await fetch(`${baseUrl}/auth/me`, {
      method: 'GET',
      headers: {
        'Accept': 'application/json',
        'Authorization': `Bearer ${body.data.access_token}`
      }
    });
    assert(testNewToken.status === 200, 'New access token can access /auth/me successfully');
  } catch (err) {
    console.error('❌ Refresh mechanism validation failed due to request error:', err);
    process.exitCode = 1;
  }

  // --- KPI-AUTH-005: User can logout successfully ---
  try {
    const res = await fetch(`${baseUrl}/auth/logout`, {
      method: 'POST',
      headers: {
        'Accept': 'application/json',
        'Authorization': `Bearer ${accessToken}`
      }
    });
    
    assert(res.status === 200, `POST /auth/logout returns 200 OK (Actual: ${res.status})`);
    
    const body = await res.json();
    assert(body.status === 'success', 'Logout response status is "success"');
    assert(body.data.message === 'Logged out successfully.', 'Logout response contains success message');
  } catch (err) {
    console.error('❌ Logout validation failed due to request error:', err);
    process.exitCode = 1;
  }

  console.log('\n🏁 API Integration Testing Completed.');
}

run();
