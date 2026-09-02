-- Route du Futur — schéma Postgres/Supabase
-- Voir docs/plan-backend.md pour le contexte complet.
-- À exécuter une fois dans l'éditeur SQL du projet Supabase (Dashboard → SQL Editor → New query).

-- ============================================================
-- 1. Référentiel : universités, Masters, bourses
--    (publiques en lecture, écriture réservée à un rôle admin)
-- ============================================================

create table universities (
  id text primary key,               -- ex. 'ox', 'mit', 'ucl'
  name text not null,
  country text not null check (country in ('UK','US'))
);

create type source_confidence as enum (
  'official_page',        -- lu directement sur la page officielle (Claude for Chrome)
  'websearch_official',   -- résumé WebSearch citant une page officielle, non vérifié mot-à-mot
  'websearch_thirdparty'  -- estimation via agrégateur tiers, non officielle
);

create table masters_programs (
  id text primary key,               -- ex. 'ox-acs', 'cmu-msaii'
  university_id text not null references universities(id),
  program_name text not null,
  tags text[] not null default '{}', -- ex. {'IA','Computer Science'}
  req_avg numeric,                   -- null = "non trouvé", jamais une valeur devinée
  req_label text,
  req_ielts numeric,                 -- null = "non trouvé"
  english_note text,
  cost text,                         -- texte libre : les coûts réels sont trop hétérogènes pour un numeric
  deadline text,                     -- texte libre : idem pour les deadlines
  other_pieces text[] not null default '{}',
  excluded boolean not null default false,   -- true = pas de master ouvert aux externes (MIT EECS, Caltech...)
  exclusion_note text,
  source_confidence source_confidence not null default 'official_page',
  updated_at timestamptz not null default now()
);

create table scholarships (
  id text primary key,               -- ex. 'chevening', 'fulbright'
  name text not null,
  coverage text,
  applies text,
  deadline text,                     -- texte libre (ISO ou description : cycle décentralisé, deadline non publiée...)
  eligibility_note text,             -- ce qui manque au profil type (ou null si a priori éligible)
  source_confidence source_confidence not null default 'websearch_official',
  updated_at timestamptz not null default now()
);

-- ============================================================
-- 2. Données étudiant (privées, une ligne par étudiant connecté)
-- ============================================================

create table students (
  id uuid primary key references auth.users(id) on delete cascade,
  name text,
  institution text default 'Lancaster University (Ghana)',
  current_year text,
  english_exempt boolean not null default true,
  ielts_score numeric,
  created_at timestamptz not null default now()
);

create table student_modules (
  id uuid primary key default gen_random_uuid(),
  student_id uuid not null references students(id) on delete cascade,
  part_year int not null,            -- 2, 3...
  year_label text not null,          -- '2025/26'
  code text not null,
  name text not null,
  credits int not null,
  indicative boolean not null default false  -- true = structure pas encore confirmée par le département
);

create table student_components (
  id uuid primary key default gen_random_uuid(),
  module_id uuid not null references student_modules(id) on delete cascade,
  name text not null,                -- 'Coursework', 'Exam'...
  weight numeric not null,           -- en %
  mark numeric                       -- null = pas encore rentrée
);

-- ============================================================
-- 3. Row Level Security
-- ============================================================

alter table universities enable row level security;
alter table masters_programs enable row level security;
alter table scholarships enable row level security;
alter table students enable row level security;
alter table student_modules enable row level security;
alter table student_components enable row level security;

-- Référentiel : lecture publique pour tout le monde (y compris non connecté)
create policy "public read universities" on universities for select using (true);
create policy "public read masters_programs" on masters_programs for select using (true);
create policy "public read scholarships" on scholarships for select using (true);

-- Référentiel : écriture réservée à un rôle admin (à créer dans Supabase Auth,
-- ex. en ajoutant un champ custom claim "role: admin" au compte concerné)
create policy "admin write universities" on universities for all
  using (auth.jwt() ->> 'role' = 'admin') with check (auth.jwt() ->> 'role' = 'admin');
create policy "admin write masters_programs" on masters_programs for all
  using (auth.jwt() ->> 'role' = 'admin') with check (auth.jwt() ->> 'role' = 'admin');
create policy "admin write scholarships" on scholarships for all
  using (auth.jwt() ->> 'role' = 'admin') with check (auth.jwt() ->> 'role' = 'admin');

-- Données étudiant : chacun ne voit/modifie que ses propres lignes
create policy "own student row" on students for all
  using (auth.uid() = id) with check (auth.uid() = id);

create policy "own student_modules" on student_modules for all
  using (auth.uid() = student_id) with check (auth.uid() = student_id);

create policy "own student_components" on student_components for all
  using (
    auth.uid() = (select student_id from student_modules where student_modules.id = module_id)
  ) with check (
    auth.uid() = (select student_id from student_modules where student_modules.id = module_id)
  );
