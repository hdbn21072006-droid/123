# Deployment Guide

This guide will help you deploy the Student Management System to:
- **Frontend**: Netlify
- **Backend**: Render
- **Database**: TiDB Cloud or Aiven MySQL

## Prerequisites

- GitHub account with repository access
- Netlify account
- Render account
- TiDB Cloud or Aiven MySQL account
- Gmail account for email functionality (optional)
- Google AI Studio account for Gemini API (optional)

---

## Step 1: Database Setup (TiDB Cloud or Aiven MySQL)

### Option A: TiDB Cloud

1. Go to [TiDB Cloud](https://tidbcloud.com)
2. Sign up and create a free cluster
3. After cluster creation, click "Connect"
4. Copy the connection details:
   - Host (e.g., `gateway.region.tidbcloud.com`)
   - Port (usually `4000`)
   - Username
   - Password
   - Database name (create a database named `student_management`)

### Option B: Aiven MySQL

1. Go to [Aiven](https://aiven.io)
2. Sign up and create a MySQL service
3. Copy the connection details from the service overview
4. Create a database named `student_management`

---

## Step 2: Backend Deployment (Render)

### 2.1 Prepare the Backend

1. Update the backend CORS configuration in `src/backend/index.ts`:
   ```typescript
   cors: {
     origin: ['https://your-netlify-app.netlify.app', 'http://localhost:8000'],
     methods: ['GET', 'POST'],
     credentials: true,
   },
   ```

2. Commit and push changes to GitHub:
   ```bash
   git add .
   git commit -m "Add deployment configurations"
   git push origin main
   ```

### 2.2 Deploy to Render

1. Go to [Render Dashboard](https://dashboard.render.com)
2. Click "New +" → "Web Service"
3. Connect your GitHub repository
4. Configure the service:
   - **Name**: `student-management-backend`
   - **Region**: Choose nearest region
   - **Branch**: `main`
   - **Runtime**: `Node`
   - **Build Command**: `npm install && npm run build`
   - **Start Command**: `npm start`
   - **Instance Type**: `Free`

5. Add Environment Variables:
   - `NODE_ENV` = `production`
   - `PORT` = `8080`
   - `BACKEND_PORT` = `8080`
   - `DB_HOST` = (your database host from Step 1)
   - `DB_PORT` = (your database port from Step 1)
   - `DB_USER` = (your database username)
   - `DB_PASSWORD` = (your database password)
   - `DB_NAME` = `student_management`
   - `JWT_SECRET` = (generate a strong random string)
   - `GMAIL_EMAIL` = (your Gmail address, optional)
   - `GMAIL_APP_PASSWORD` = (your Gmail app password, optional)
   - `LLM_PROVIDER` = `gemini`
   - `GEMINI_API_KEY` = (your Gemini API key, optional)
   - `GEMINI_MODEL` = `gemini-2.0-flash`
   - `MAX_HISTORY_PAIRS` = `10`
   - `TOP_K_CHUNKS` = `5`
   - `ALLOWED_ORIGINS` = (your Netlify frontend URL, e.g., `https://your-app.netlify.app,http://localhost:8000`)

6. Click "Deploy Web Service"
7. Wait for deployment to complete (2-5 minutes)
8. Copy the backend URL (e.g., `https://student-management-backend.onrender.com`)

### 2.3 Run Database Migration

After backend deployment, you need to run the database migration:

1. Go to Render Dashboard → your backend service
2. Click "Shell" (or use Render's one-off job feature)
3. Run the migration command:
   ```bash
   npm run migrate
   ```

Or you can run it locally with production database credentials:
```bash
DB_HOST=your_db_host DB_PORT=your_db_port DB_USER=your_user DB_PASSWORD=your_password npm run migrate
```

---

## Step 3: Frontend Deployment (Netlify)

### 3.1 Update Frontend Configuration

1. Update the backend API URL in `src/frontend/services/config.ts`:
   ```typescript
   // Replace with your Render backend URL
   const BASE_URL = 'https://student-management-backend.onrender.com';
   ```

2. Commit and push changes:
   ```bash
   git add .
   git commit -m "Update backend API URL for production"
   git push origin main
   ```

### 3.2 Deploy to Netlify

1. Go to [Netlify Dashboard](https://app.netlify.com)
2. Click "Add new site" → "Import an existing project"
3. Connect your GitHub repository
4. Configure build settings:
   - **Build command**: `npm run build`
   - **Publish directory**: `dist`
   - **Node version**: `16`

5. Add environment variables (optional, if needed):
   - `REACT_APP_API_URL` = (your Render backend URL)

6. Click "Deploy site"
7. Wait for deployment to complete (2-3 minutes)
8. Copy the frontend URL (e.g., `https://your-app.netlify.app`)

---

## Step 4: Update Backend CORS (Final)

After you have the Netlify frontend URL, update the backend CORS:

1. Go to Render Dashboard → your backend service
2. Click "Environment"
3. Update the allowed origins in your code or add environment variable if you've refactored
4. Redeploy the backend

---

## Step 5: Test the Deployment

1. Visit your Netlify frontend URL
2. Try to:
   - Register a new user
   - Login
   - Access student/admin features
3. Check the Render logs for any errors
4. Verify database connection in Render logs

---

## Troubleshooting

### Backend Issues

- **Database connection failed**: Verify database credentials and network access
- **Port already in use**: Render automatically assigns ports, ensure you're using `process.env.PORT`
- **Build failed**: Check Render build logs for dependency issues

### Frontend Issues

- **API calls failing**: Check CORS configuration and backend URL
- **Build failed**: Ensure Node version is set to 16 in Netlify
- **Blank page**: Check browser console for errors

### Database Issues

- **Migration failed**: Run migration manually with correct credentials
- **Connection timeout**: Check if database allows external connections from Render's IP ranges

---

## Cost Summary

- **Netlify**: Free tier available (100GB bandwidth/month)
- **Render**: Free tier available (750 hours/month)
- **TiDB Cloud**: Free tier available (5GB storage)
- **Aiven MySQL**: Free trial available, then paid

---

## Maintenance

- Monitor Render logs regularly
- Keep dependencies updated
- Backup database regularly
- Update environment variables as needed
- Monitor API usage and limits

---

## Security Notes

- Never commit `.env` files to GitHub
- Use strong JWT secrets
- Rotate API keys regularly
- Enable HTTPS (automatic on Netlify and Render)
- Implement rate limiting for API endpoints
