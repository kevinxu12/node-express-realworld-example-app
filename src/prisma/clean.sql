-- Leaves tables in-tact but clears the data in all of teh tablesimport { PrismaClient } from '@prisma/client';

DELETE FROM "Comment";

-- Deletes all articles
DELETE FROM "Article";

-- Deletes all users
DELETE FROM "User";

DELETE FROM "Tag";