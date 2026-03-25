-- Comments
create table comments (
  id uuid default gen_random_uuid() primary key,
  post_slug text not null,
  name text not null,
  body text not null,
  parent_id uuid references comments(id) on delete cascade,
  created_at timestamptz default now(),
  constraint name_not_empty check (length(trim(name)) > 0),
  constraint body_not_empty check (length(trim(body)) > 0),
  constraint body_max_length check (length(body) <= 2000)
);

-- Reactions (emoji reactions on posts)
create table reactions (
  id uuid default gen_random_uuid() primary key,
  post_slug text not null,
  emoji text not null,
  created_at timestamptz default now()
);

-- Votes on individual comments
create table comment_votes (
  id uuid default gen_random_uuid() primary key,
  comment_id uuid references comments(id) on delete cascade,
  vote_type text not null check (vote_type in ('up', 'down')),
  created_at timestamptz default now()
);

-- RLS
alter table comments enable row level security;
alter table reactions enable row level security;
alter table comment_votes enable row level security;

create policy "insert comments" on comments for insert with check (true);
create policy "read all comments" on comments for select using (true);

create policy "insert reactions" on reactions for insert with check (true);
create policy "read reactions" on reactions for select using (true);

create policy "insert votes" on comment_votes for insert with check (true);
create policy "read votes" on comment_votes for select using (true);
