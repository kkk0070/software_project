import os

file_path = r'c:\Users\punit\Downloads\software_project\backend\src\controllers\shared\authController.js'

with open(file_path, 'r', encoding='utf-8') as f:
    content = f.read()

# Replace in login
target_login = """    const token = generateToken(user.id, user.email, user.role, null);

    // Track active device session
    const refreshToken = crypto.randomBytes(40).toString('hex');
    await knex('device_sessions').insert({
      user_id: user.id,
      refresh_token: refreshToken,
      device_info: req.headers['user-agent'] || 'Unknown Device',
      ip_address: req.ip || req.connection?.remoteAddress || 'Unknown IP'
    });"""

replacement_login = """    // Track active device session
    const refreshToken = crypto.randomBytes(40).toString('hex');
    const [session] = await knex('device_sessions')
      .insert({
        user_id: user.id,
        refresh_token: refreshToken,
        device_info: req.headers['user-agent'] || 'Unknown Device',
        ip_address: req.ip || req.connection?.remoteAddress || 'Unknown IP'
      })
      .returning('id');

    const sessionId = session?.id || session;

    // Generate JWT token with sessionId
    const token = generateToken(user.id, user.email, user.role, sessionId);"""

content = content.replace(target_login, replacement_login)

# Replace in verifyLoginOTP
# Need to find the exact target for verifyLoginOTP
target_verify = """    // Generate JWT token
    const token = generateToken(user.id, user.email, user.role);

    // Track active device session
    const refreshToken = crypto.randomBytes(40).toString('hex');
    await knex('device_sessions').insert({
      user_id: user.id,
      refresh_token: refreshToken,
      device_info: req.headers['user-agent'] || 'Unknown Device',
      ip_address: req.ip || req.connection?.remoteAddress || 'Unknown IP'
    });"""

replacement_verify = """    // Track active device session
    const refreshToken = crypto.randomBytes(40).toString('hex');
    const [session] = await knex('device_sessions')
      .insert({
        user_id: user.id,
        refresh_token: refreshToken,
        device_info: req.headers['user-agent'] || 'Unknown Device',
        ip_address: req.ip || req.connection?.remoteAddress || 'Unknown IP'
      })
      .returning('id');

    const sessionId = session?.id || session;

    // Generate JWT token with sessionId
    const token = generateToken(user.id, user.email, user.role, sessionId);"""

content = content.replace(target_verify, replacement_verify)

with open(file_path, 'w', encoding='utf-8') as f:
    f.write(content)

print("Success")
