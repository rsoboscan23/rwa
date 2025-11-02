# ER Diagram Structure - Visual Guide

## Entity-Relationship Diagram Overview

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                   RWA MULTIMEDIA MANAGEMENT SYSTEM                           │
│                          ER DIAGRAM STRUCTURE                                │
└─────────────────────────────────────────────────────────────────────────────┘

┌──────────────┐         ┌──────────────────┐
│    roles     │         │      users       │
├──────────────┤    1    ├──────────────────┤
│ id (PK)      │←────────│ id (PK)          │
│ name         │       ∞ │ username         │
│ level        │         │ email            │
│ description  │         │ password_hash    │
│ created_at   │         │ first_name       │
└──────────────┘         │ last_name        │
                         │ role_id (FK)     │
                         │ is_active        │
                         │ email_verified   │
                         │ created_at       │
                         │ updated_at       │
                         │ last_login       │
                         └──────────────────┘
                                │
                                │ 1 (added_by)
                                │
                                ↓
                         ┌──────────────────────────┐
                         │      media_items         │
                         ├──────────────────────────┤
                         │ id (PK)                  │
                         │ title                    │
                         │ original_title           │
                         │ media_type               │
                         │ description              │
                         │ release_date             │
                         │ runtime                  │
                         │ poster_url               │
                         │ backdrop_url             │
                         │ trailer_url              │
                         │ tmdb_id                  │
                         │ imdb_id                  │
                         │ source                   │
                         │ language                 │
                         │ country                  │
                         │ budget                   │
                         │ revenue                  │
                         │ status                   │
                         │ popularity               │
                         │ vote_average             │
                         │ vote_count               │
                         │ added_by_user_id (FK)    │
                         │ is_approved              │
                         │ approved_by_user_id (FK) │
                         │ created_at               │
                         │ updated_at               │
                         └──────────────────────────┘
                    ∞            │            ∞
          ┌─────────────────────┼─────────────────────┐
          │                     │                     │
          ↓                     ↓                     ↓
┌─────────────────┐   ┌─────────────────┐   ┌─────────────────┐
│  media_genres   │   │  media_actors   │   │    reviews      │
├─────────────────┤   ├─────────────────┤   ├─────────────────┤
│ id (PK)         │   │ id (PK)         │   │ id (PK)         │
│ media_id (FK)   │   │ media_id (FK)   │   │ media_id (FK)   │
│ genre_id (FK)   │   │ actor_id (FK)   │   │ user_id (FK)    │
└─────────────────┘   │ character_name  │   │ title           │
          │           │ cast_order      │   │ content         │
          │           └─────────────────┘   │ is_approved     │
          │                     │           │ approved_by     │
          │ ∞                   │ ∞         │ created_at      │
          ↓                     ↓           │ updated_at      │
┌─────────────────┐   ┌─────────────────┐   └─────────────────┘
│     genres      │   │     actors      │
├─────────────────┤   ├─────────────────┤
│ id (PK)         │   │ id (PK)         │
│ name            │   │ name            │
│ tmdb_id         │   │ birth_date      │
│ created_at      │   │ biography       │
└─────────────────┘   │ profile_url     │
                      │ tmdb_id         │
                      │ created_at      │
                      └─────────────────┘


        users + media_items Interaction Tables:

┌─────────────────┐              ┌──────────────────┐
│    ratings      │              │ user_favorites   │
├─────────────────┤              ├──────────────────┤
│ id (PK)         │              │ id (PK)          │
│ media_id (FK)   │              │ user_id (FK)     │
│ user_id (FK)    │              │ media_id (FK)    │
│ rating          │              │ created_at       │
│ created_at      │              └──────────────────┘
│ updated_at      │
└─────────────────┘
```

## Relationship Cardinality

### One-to-Many Relationships

1. **roles → users** (1:∞)
   - One role can be assigned to many users
   - Each user has exactly one role

2. **users → media_items** (1:∞) [added_by]
   - One user can add many media items
   - Each media item is added by one user (or NULL)

3. **users → media_items** (1:∞) [approved_by]
   - One moderator/admin can approve many media items
   - Each approved media item has one approver (or NULL)

4. **users → reviews** (1:∞)
   - One user can write many reviews
   - Each review belongs to one user

5. **media_items → reviews** (1:∞)
   - One media item can have many reviews
   - Each review is for one media item

6. **users → ratings** (1:∞)
   - One user can rate many media items
   - Each rating belongs to one user

7. **media_items → ratings** (1:∞)
   - One media item can have many ratings
   - Each rating is for one media item

### Many-to-Many Relationships

1. **media_items ↔ genres** (∞:∞)
   - Through: media_genres table
   - One media item can have multiple genres
   - One genre can be assigned to multiple media items

2. **media_items ↔ actors** (∞:∞)
   - Through: media_actors table
   - One media item can have multiple actors
   - One actor can appear in multiple media items
   - Additional data: character_name, cast_order

3. **users ↔ media_items** (∞:∞) [favorites]
   - Through: user_favorites table
   - One user can favorite multiple media items
   - One media item can be favorited by multiple users

## Key Constraints

### Unique Constraints
- `users.username` - UNIQUE
- `users.email` - UNIQUE
- `roles.name` - UNIQUE
- `genres.name` - UNIQUE
- `ratings(user_id, media_id)` - UNIQUE (one rating per user per media)
- `user_favorites(user_id, media_id)` - UNIQUE (no duplicate favorites)
- `media_actors(media_id, actor_id)` - UNIQUE (no duplicate cast entries)
- `media_genres(media_id, genre_id)` - UNIQUE (no duplicate genre assignments)

### Check Constraints
- `ratings.rating` - Must be between 0.0 and 10.0

### Foreign Key Actions
- **ON DELETE CASCADE**: When parent is deleted, children are deleted
  - media_items → reviews
  - media_items → ratings
  - media_items → user_favorites
  - media_items → media_genres
  - media_items → media_actors
  - users → reviews
  - users → ratings
  - users → user_favorites

- **ON DELETE SET NULL**: When parent is deleted, FK is set to NULL
  - users → media_items (added_by)
  - users → media_items (approved_by)
  - users → reviews (approved_by)

- **ON DELETE RESTRICT**: Prevents deletion if children exist
  - roles → users

## Indexes for Performance

### Primary Indexes (Automatic)
- All `id` columns (PRIMARY KEY)

### Secondary Indexes

**users table:**
- `idx_username` on username
- `idx_email` on email
- `idx_role_id` on role_id

**media_items table:**
- `idx_title` on title
- `idx_media_type` on media_type
- `idx_tmdb_id` on tmdb_id
- `idx_source` on source
- `idx_release_date` on release_date
- `idx_popularity` on popularity
- `idx_is_approved` on is_approved

**actors table:**
- `idx_name` on name
- `idx_tmdb_id` on tmdb_id

**genres table:**
- `idx_name` on name

**Relationship tables:**
- Indexes on all foreign key columns
- Indexes on frequently queried columns (created_at, etc.)

## Hierarchical Role System

```
Level 4: ADMIN
   │
   ├─ Full system access
   ├─ User management
   ├─ All moderator capabilities
   │
Level 3: MODERATOR
   │
   ├─ Content approval/rejection
   ├─ Review moderation
   ├─ All user capabilities
   │
Level 2: USER
   │
   ├─ Add content (requires approval)
   ├─ Rate media
   ├─ Write reviews (requires approval)
   ├─ Add favorites
   ├─ All guest capabilities
   │
Level 1: GUEST
   │
   ├─ View approved content
   ├─ View approved reviews
   ├─ Browse media catalog
   └─ Read-only access
```

## TMDB Integration Points

The schema is designed to integrate with The Movie Database (TMDB) API:

1. **media_items.tmdb_id** - Links to TMDB movie/TV show ID
2. **media_items.imdb_id** - Links to IMDB ID
3. **media_items.source** - Indicates if content is from 'tmdb' or 'internal'
4. **actors.tmdb_id** - Links to TMDB person ID
5. **genres.tmdb_id** - Links to TMDB genre ID

## Pagination Strategy

For large datasets, use the provided stored procedures:

1. **sp_get_paginated_media**
   - Parameters: page, page_size, media_type, search_term, order_by
   - Returns: paginated results + total count
   - Server-side filtering and sorting

2. **sp_get_paginated_users**
   - Parameters: page, page_size, role_id, search_term
   - Returns: paginated results + total count
   - Admin-only access

### Example Usage:
```sql
-- Get page 1 with 20 items per page, movies only, sorted by popularity
CALL sp_get_paginated_media(1, 20, 'movie', NULL, 'popularity_desc');

-- Get page 2 of users with role_id 2 (regular users)
CALL sp_get_paginated_users(2, 50, 2, NULL);
```

## Views for Reporting

### v_users_with_roles
Combines user information with role details for easy querying.

### v_media_with_stats
Provides aggregated statistics for each media item:
- Average user rating
- Rating count
- Review count
- Favorite count
- Concatenated list of genres

## Implementation Checklist

When implementing this schema in MySQL Workbench:

1. ✅ Create all tables with proper data types
2. ✅ Set up primary keys on all tables
3. ✅ Create foreign key relationships with proper constraints
4. ✅ Add unique constraints where specified
5. ✅ Add check constraints (rating range)
6. ✅ Create indexes for performance
7. ✅ Add the four default roles
8. ✅ Add standard genres
9. ✅ Create views for reporting
10. ✅ Create stored procedures for pagination
11. ✅ Set proper character encoding (utf8mb4)
12. ✅ Configure ON DELETE/UPDATE actions
13. ✅ Add default values where appropriate
14. ✅ Set timestamp auto-update triggers

## MySQL Workbench Tips

1. **Auto-arrange**: Use `Arrange → Auto-Layout` to organize tables
2. **Relationship lines**: Double-click to add anchor points
3. **Table colors**: Right-click table → Color to color-code by category
4. **Notes**: Add text boxes to document special considerations
5. **Export**: Use `File → Export → Forward Engineer SQL CREATE Script`

