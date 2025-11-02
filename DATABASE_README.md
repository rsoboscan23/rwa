# Database Schema for RWA Multimedia Management Application

## Overview

This database schema is designed for a multimedia management web application that:
- Manages multimedia collections from TMDB service and internal content
- Implements hierarchical user roles: **Admin > Moderator > User > Guest**
- Supports server-side pagination for large datasets
- Includes user authentication, content management, ratings, reviews, and favorites

## How to Create ER Diagram in MySQL Workbench

### Method 1: Reverse Engineer from Existing Database

1. **Import the schema to your MySQL server:**
   ```bash
   mysql -u username -p database_name < database_schema.sql
   ```

2. **Open MySQL Workbench**

3. **Reverse Engineer the Database:**
   - Go to `Database` → `Reverse Engineer`
   - Connect to your MySQL server
   - Select your database
   - Click through the wizard to generate the ER diagram
   - The ER diagram will be automatically created showing all tables and relationships

### Method 2: Create Model Directly (Recommended)

1. **Open MySQL Workbench**

2. **Create New Model:**
   - Go to `File` → `New Model`

3. **Add EER Diagram:**
   - Click `Add Diagram` button or double-click "Add Diagram" in the model

4. **Import SQL Script:**
   - In the model view, go to `File` → `Import` → `Reverse Engineer MySQL Create Script...`
   - Select the `database_schema.sql` file
   - The tool will parse the SQL and create the ER diagram automatically

5. **Arrange the Diagram:**
   - MySQL Workbench will place all tables on the canvas
   - Use the auto-arrange feature: `Arrange` → `Auto-Layout`
   - Manually adjust table positions for better visualization

### Method 3: Manual Creation

If you want to create it manually in MySQL Workbench:

1. Create a new model (`File` → `New Model`)
2. Add a new EER Diagram
3. Use the tools in the left panel to:
   - Add tables (use the table icon)
   - Define columns with proper data types
   - Create relationships by clicking the relationship icons and connecting tables
   - Set foreign key constraints

## Database Structure

### Core Tables

#### 1. **roles**
- Defines user role hierarchy (guest=1, user=2, moderator=3, admin=4)
- Each higher role inherits permissions from lower roles

#### 2. **users**
- Stores user account information
- Links to `roles` table via `role_id`
- Includes authentication fields (password_hash, email_verified)
- Tracks user activity (last_login, is_active)

#### 3. **media_items**
- Central table for all multimedia content
- Supports multiple media types (movie, tv_series, music, podcast, book, game)
- Integrates with TMDB service (tmdb_id, source)
- Includes moderation fields (is_approved, approved_by_user_id)
- Tracks popularity and ratings

#### 4. **actors**
- Stores actor/cast information
- Can be linked to TMDB via tmdb_id

#### 5. **genres**
- Catalog of content genres
- Linked to TMDB genre IDs

### Relationship Tables (Many-to-Many)

#### 6. **media_actors**
- Links media items to actors
- Includes character_name and cast_order

#### 7. **media_genres**
- Links media items to genres

### User Interaction Tables

#### 8. **reviews**
- User-written reviews for media items
- Includes moderation (is_approved, approved_by_user_id)

#### 9. **ratings**
- User ratings (0.0 to 10.0) for media items
- One rating per user per media item

#### 10. **user_favorites**
- Tracks users' favorite media items

## Key Features

### Hierarchical Access Control
```
Admin (level 4) - Full system access
  ↓
Moderator (level 3) - Can approve content and reviews
  ↓
User (level 2) - Can rate, review, and favorite content
  ↓
Guest (level 1) - Read-only access
```

### Pagination Support
The schema includes stored procedures for server-side pagination:
- `sp_get_paginated_media` - Paginate media items with filtering and sorting
- `sp_get_paginated_users` - Paginate users (admin only)

### Views for Easy Querying
- `v_users_with_roles` - Users with role information
- `v_media_with_stats` - Media items with aggregated statistics

## Entity Relationships

### Primary Relationships:
1. **users** → **roles** (Many-to-One)
2. **media_items** → **users** (Many-to-One for added_by and approved_by)
3. **media_items** ↔ **actors** (Many-to-Many via media_actors)
4. **media_items** ↔ **genres** (Many-to-Many via media_genres)
5. **users** + **media_items** → **ratings** (One rating per user per media)
6. **users** + **media_items** → **reviews** (Many reviews possible)
7. **users** + **media_items** → **user_favorites** (Many-to-Many)

## Sample Data

The schema includes:
- 4 predefined roles (guest, user, moderator, admin)
- 19 standard genres (matching TMDB genre structure)
- 1 default admin user (username: 'admin', password must be changed)

## Usage Notes

1. **Security**: The default admin password hash is a placeholder. Update it before production use.

2. **TMDB Integration**: Fields like `tmdb_id`, `imdb_id` facilitate integration with The Movie Database API.

3. **Moderation Workflow**: Content can be added by users but requires approval (is_approved flag) by moderators/admins.

4. **Indexes**: The schema includes strategic indexes on frequently queried columns for performance.

5. **Character Set**: Uses utf8mb4 to support international characters and emojis.

## Next Steps

After creating the ER diagram:
1. Review the relationships and adjust as needed
2. Add custom tables for specific requirements
3. Export the forward-engineered SQL if modifications were made
4. Implement the database in your application
5. Create appropriate API endpoints with role-based access control
6. Implement server-side pagination using the provided stored procedures

## Requirements Met

This schema fulfills the requirements from "RWA zadaća 1":
- ✅ Multimedia collection management
- ✅ TMDB service integration (via tmdb_id fields)
- ✅ Internal content management (via source field)
- ✅ 4-tier hierarchical user roles
- ✅ Access control structure (role levels)
- ✅ Server-side pagination (stored procedures)
- ✅ Comprehensive data model for web application

