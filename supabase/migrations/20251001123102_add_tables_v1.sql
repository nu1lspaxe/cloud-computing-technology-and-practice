CREATE EXTENSION IF NOT EXISTS "pgcrypto";

CREATE SCHEMA "e";

CREATE SCHEMA "internal";

CREATE TYPE "e"."owner_type" AS ENUM (
  'User'
);

CREATE TYPE "e"."item_type" AS ENUM (
  'Properties',
  'Clothes'
);

CREATE TYPE "e"."gender" AS ENUM (
  'Man',
  'Woman',
  'Non-binary',
  'Transgender'
);

CREATE TYPE "e"."relationship_status" AS ENUM (
  'Single',
  'Friends',
  'Open Relationship',
  'In Relationship',
  'Dating',
  'Married'
);

CREATE TYPE "e"."species" AS ENUM (
  'Dog',
  'Cat'
);

CREATE TABLE "users" (
  "id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  "email" varchar NOT NULL UNIQUE,
  "gender" e.gender DEFAULT NULL,
  "relationship" e.relationship_status DEFAULT NULL,
  "dob" date DEFAULT NULL
);

CREATE TABLE "pets" (
  "id" uuid PRIMARY KEY,
  "user_id" uuid UNIQUE NOT NULL,
  "species" e.species NOT NULL,
  "color" varchar(6),
  "hp" int NOT NULL,
  "created_at" timestamptz,
  "updated_at" timestamptz
);

CREATE TABLE "store_items" (
  "id" uuid PRIMARY KEY,
  "item_type" e.item_type NOT NULL,
  "ref_id" int,
  "price" money NOT NULL,
  "stock" int
);

CREATE TABLE "internal"."accounts" (
  "id" uuid PRIMARY KEY,
  "user_id" uuid UNIQUE NOT NULL,
  "points" money NOT NULL
);

CREATE TABLE "records" (
  "id" uuid PRIMARY KEY,
  "user_id" uuid NOT NULL,
  "start_time" timestamptz NOT NULL,
  "end_time" timestamptz NOT NULL,
  "description" varchar(100)
);

CREATE TABLE "storage_items" (
  "id" uuid PRIMARY KEY,
  "owner_type" e.owner_type NOT NULL,
  "owner_id" int NOT NULL,
  "item_type" e.item_type NOT NULL,
  "item_id" int NOT NULL,
  "quantity" int NOT NULL
);

CREATE TABLE "internal"."properties" (
  "id" uuid PRIMARY KEY,
  "name" varchar,
  "energy_point" int
);

CREATE TABLE "internal"."clothes" (
  "id" uuid PRIMARY KEY,
  "name" varchar,
  "bonus_point" int
);

CREATE INDEX "idx_records_user_id_start" ON public.records ("user_id", "start_time");

CREATE INDEX "idx_owner_storage_item" ON public.storage_items ("owner_type", "owner_id", "item_type", "item_id");

ALTER TABLE public.pets ADD FOREIGN KEY ("user_id") REFERENCES "users" ("id");

ALTER TABLE internal.accounts ADD FOREIGN KEY ("user_id") REFERENCES "users" ("id");

ALTER TABLE public.records ADD FOREIGN KEY ("user_id") REFERENCES "users" ("id");
